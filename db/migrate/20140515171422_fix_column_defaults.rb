class FixColumnDefaults < ActiveRecord::Migration
  ENTITY_COLUMNS_TO_FIX = [
    :address_line_1,
    :address_line_2,
    :state,
    :country_code,
    :phone,
    :email,
    :url,
    :city,
    :zip,
  ]

  ALL_ENTITY_INDEXES = %w|
    address_line_1
    ancestry
    city
    country_code
    email
    name
    phone
    state
    user_id
    zip
  |

  def up
    init_statements
    remove_indexes

    ENTITY_COLUMNS_TO_FIX.each do |column|
      change_column_default(:entities, column, '')
      fix_null_for(:entities, column)
    end

    add_temp_index

    fix_duplicate_entities

    remove_temp_index
    add_indexes

    change_column_default(:topics, :description, '')
    fix_null_for(:topics, :description)
  end

  def down
    # This is incomplete as the up method is destructive.
    ENTITY_COLUMNS_TO_FIX.each do |column|
      change_column_default(:entities, column, nil)
    end

    change_column_default(:topics, :description, nil)
  end

  def fix_null_for(table, column)
    execute "UPDATE #{table} set #{column}='' where #{column} IS NULL"
  end

  def pg_conn
    ActiveRecord::Base.connection.raw_connection
  end

  DEDUPE_ATTRS = %w|name address_line_1 city state zip country_code phone email|

  def init_statements
    pg_conn.prepare(
      'find_duplicate_entity',
      'SELECT * from entities WHERE
name=$1 AND
address_line_1=$2 AND
city=$3 AND
state=$4 AND
zip=$5 AND
country_code=$6 AND
phone=$7 AND
email=$8 AND
id <> $9')

    pg_conn.prepare('find_entity', 'select * from entities where id=$1')
  end

  def find_duplicates_of(entity)
    pg_conn.exec_prepared(
      'find_duplicate_entity',
      [ DEDUPE_ATTRS.map{ |attr| entity[attr] }, entity['id'].to_i ].flatten
    )
  end

  def fix_duplicate_entities
    duplicate_entities = execute(
      'SELECT min(id) AS id
      FROM entities
      GROUP BY
      name, address_line_1, city, state, zip, country_code, phone, email
      having count(*) > 1'
    )

    duplicate_entity_ids = duplicate_entities.to_a.map{ |e| e['id'].to_i }.sort

    duplicate_entity_ids.each do |entity_id|
      entity_row = pg_conn.exec_prepared('find_entity', [entity_id]).first
      # entity_id might've already been merged, so check that we found it first.
      next if entity_row.nil?

      find_duplicates_of(entity_row).each do |duplicate|
        execute(
          "UPDATE entity_notice_roles
          SET entity_id = #{entity_id}
          WHERE entity_id = #{duplicate['id']}"
        )
        execute("delete from entities where id = #{duplicate['id']}")
      end
    end
  end

  def remove_indexes
    remove_index :entities, name: :unique_entity_attribute_index
    ALL_ENTITY_INDEXES.each do |column|
      remove_index :entities, column
    end
  end

  def add_temp_index
    add_index :entities, [
      :name,
      :address_line_1,
      :city,
      :state,
      :zip,
      :country_code,
      :phone,
      :email,
    ], name: 'temp_entity_attribute_index'
  end

  def remove_temp_index
    remove_index :entities, name: :temp_entity_attribute_index
  end

  def add_indexes
    add_index :entities, [
      :name,
      :address_line_1,
      :city,
      :state,
      :zip,
      :country_code,
      :phone,
      :email,
    ], unique: true, name: 'unique_entity_attribute_index'
    ALL_ENTITY_INDEXES.each do |column|
      add_index :entities, column
    end
  end
end
