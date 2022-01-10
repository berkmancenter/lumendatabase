class AddYoutubeEntity < ActiveRecord::Migration[5.2]
  def change
    Entity.import([
      Entity.new(
        name: 'YouTube Legal Support',
        kind: 'organization',
        address_line_1: ' 901 Cherry Ave.',
        state: 'CA',
        country_code: 'US',
        city: 'San Bruno',
        zip: '94066',
        name_original: 'YouTube Legal Support'
      )
    ])
  end
end
