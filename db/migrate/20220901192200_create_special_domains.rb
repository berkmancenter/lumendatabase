class CreateSpecialDomains < ActiveRecord::Migration[6.1]
  def change
    create_table :special_domains do |t|
      t.string :domain_name
      t.text :notes
      t.jsonb :why_special

      t.timestamps
    end
  end
end
