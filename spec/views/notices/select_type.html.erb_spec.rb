require 'spec_helper'

describe 'notices/select_type.html.erb' do
  it "is not missing any translations" do
    render

    expect(page).not_to have_css('.translation_missing')
  end

  Notice.type_models.each do |model|
    it "displays the correct descriptive text for #{model} notices" do
      render

      within("div[data-id=#{model.name}]") do
        expect(page).to have_content t("type_descriptions.#{model.name}")
      end
    end
  end
end
