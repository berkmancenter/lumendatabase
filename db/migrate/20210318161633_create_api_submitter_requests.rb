class CreateApiSubmitterRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :api_submitter_requests do |t|
      t.string :email, null: false
      t.string :submissions_forward_email, null: false
      t.text :description, default: ''
      t.string :entity_name, null: false
      t.string :entity_kind, default: 'individual', null: false
      t.string :entity_address_line_1, default: ''
      t.string :entity_address_line_2, default: ''
      t.string :entity_state, default: ''
      t.string :entity_country_code, default: ''
      t.string :entity_phone, default: ''
      t.string :entity_url, default: ''
      t.string :entity_email, default: ''
      t.string :entity_city, default: ''
      t.string :entity_zip, default: ''
      t.text :admin_notes, default: ''
      t.references :user, null: true
      t.boolean :approved

      t.timestamps
    end

    add_column :users, :widget_submissions_forward_email, :string
  end
end
