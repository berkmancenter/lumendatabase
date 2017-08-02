require 'rails_helper'

describe 'views/entities/_address.html.erb' do
  it "has relevant metadata" do
    entity = build(:entity)

    render partial: 'entities/address', locals: { entity: entity }

    expect(rendered).to include entity.city
    expect(rendered).to include entity.state
    expect(rendered).to include entity.zip
    expect(rendered).to include entity.country_code
  end

  it "handles nil country_codes fine" do
    entity = build(:entity, country_code: nil)

    render partial: 'entities/address', locals: { entity: entity }

    expect(rendered).to include entity.city
  end
end
