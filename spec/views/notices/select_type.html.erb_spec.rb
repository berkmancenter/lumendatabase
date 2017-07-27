require 'rails_helper'

describe 'notices/select_type.html.erb' do
  it "is not missing any translations" do
    render

    expect(rendered).not_to have_css('.translation_missing')
  end

  Notice.type_models.each do |model|
    it "displays the correct descriptive text for #{model} notices" do
      render

      expect(rendered).to have_css( "div[data-id=#{model.name}]", text: ActionController::Base.helpers.strip_tags(t("type_descriptions.#{model.name}")))
    end
  end
end
