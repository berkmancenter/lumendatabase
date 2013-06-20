require 'spec_helper'

describe 'notices/new.html.erb' do
  it "has a form for notices" do
    assign(:notice, Notice.new)

    render

    expect(rendered).to have_css 'form'
  end

  context "category drop down" do
    it "shows the categories alphabetically" do
      second_category = create(:category, name: "B Category")
      third_category = create(:category, name: "C Category")
      first_category = create(:category, name: "A Category")
      assign(:notice, Notice.new)

      render

      within('select#notice_category_ids') do
        expect(page).to have_nth_option(1, first_category.name)
        expect(page).to have_nth_option(2, second_category.name)
        expect(page).to have_nth_option(3, third_category.name)
      end
    end

    private

    def have_nth_option(n, value)
      have_css("option:nth-child(#{n})", text: value)
    end
  end

  context "step headings" do
    it "has the correct step headings" do
      ordered_sections = %w( notice-body works submitter recipient )
      assign(:notice, build(:notice, role_names: %w( submitter recipient )))

      render

      ordered_sections.each_with_index do |section, index|
        expect(page).to have_step_heading(section, index + 1)
      end
    end

    private

    def have_step_heading(section_class, step_number)
      have_css(".#{section_class} h4:contains('Step #{step_number}.')")
    end
  end
end
