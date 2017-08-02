require 'rails_helper'

describe 'views/entity_notice_roles/_entity_notice_role.html.erb' do

  it 'shows relevant metadata' do
    entity_notice_role = build(:entity_notice_role)
    assign(:entity_notice_role, entity_notice_role)

    render partial: 'entity_notice_roles/entity_notice_role', locals: {
      entity_notice_role: entity_notice_role
    }

    expect(rendered).to include entity_notice_role.entity.name
    expect(rendered).to include entity_notice_role.entity.kind
    expect(rendered).to include entity_notice_role.name
  end

end
