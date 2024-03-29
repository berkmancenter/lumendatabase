require 'rails_helper'

describe 'notices/select_type.html.erb' do
  it 'is not missing any translations' do
    render

    expect(rendered).not_to have_css('.translation_missing')
  end

  (Notice.type_models - [Placeholder]).each do |model|
    it "displays the correct descriptive text for #{model} notices" do
      render

      expect(rendered).to have_css( "div[data-id=#{model.name}]", text: ActionController::Base.helpers.strip_tags(Translation.t("notice_type_descriptions_#{model.name}")))
    end
  end

  it 'does not allow for Placeholder creation' do
    model = Placeholder

    render

    expect(rendered).not_to have_css( "div[data-id=#{model.name}]", text: ActionController::Base.helpers.strip_tags(Translation.t("notice_type_descriptions_#{model.name}")))
  end
end
