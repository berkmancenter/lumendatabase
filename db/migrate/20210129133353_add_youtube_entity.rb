class AddYoutubeEntity < ActiveRecord::Migration[5.2]
  def change
    entity_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'entities'
    end

    entity_class.create!(
      name: 'YouTube Legal Support',
      kind: 'organization',
      address_line_1: ' 901 Cherry Ave.',
      state: 'CA',
      country_code: 'US',
      city: 'San Bruno',
      zip: '94066',
      name_original: 'YouTube Legal Support'
    )
  end
end
