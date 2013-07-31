require 'spec_helper'

feature "Fielded searches of Notices", search: true do
  include SearchHelpers

  context "via parameters only" do
    Notice::SEARCHABLE_FIELDS.reject{|f| f[:parameter] == :term}.each do |field|
      it %Q|within #{field[:name]}|, search: true do
        in_field, outside_field = FieldedSearchNoticeGenerator.generate(field)

        search_on_page = FieldedSearchOnPage.new

        search_on_page.parameterized_search_for(field[:parameter], field[:name])

        search_on_page.within_results do
          expect(page).to have_content(in_field.title)
          expect(page).not_to have_content(outside_field.title)
        end
      end
    end
  end

  context "via the web UI" do
    Notice::SEARCHABLE_FIELDS.reject{|f| f[:parameter] == :term}.each do |field|
      it "within #{field[:name]}", search: true, js: true do
        in_field, outside_field = FieldedSearchNoticeGenerator.generate(field)
        search_on_page = FieldedSearchOnPage.new
        search_on_page.visit_search_page
        search_on_page.add_fielded_search_for(field[:name], field[:name])

        search_on_page.run_search

        search_on_page.within_results do
          expect(page).to have_content(in_field.title)
          expect(page).not_to have_content(outside_field.title)
        end
      end
    end
  end

  context "advanced search behavior" do
    it "dropdown not displayed by default", js: true do
      search_on_page = FieldedSearchOnPage.new
      search_on_page.visit_search_page

      expect(page).not_to have_visible_advanced_search_controls
    end

    it "dropdown retains visibility between page views", js: true do
      pending 'Javascript set cookies do not appear to work in capybara-webkit'
      search_on_page = FieldedSearchOnPage.new
      search_on_page.visit_search_page

      search_on_page.open_advanced_search
      expect(page).to have_visible_advanced_search_controls

      search_on_page.visit_search_page
      expect(page).to have_visible_advanced_search_controls
    end

    it "retains query parameters", js: true do
      search_on_page = FieldedSearchOnPage.new
      search_on_page.visit_search_page
      search_on_page.open_advanced_search
      search_on_page.add_fielded_search_for('Title', 'lion')

      search_on_page.run_search
      search_on_page.open_advanced_search

      expect(page).to have_css('.field-group.title', visible: true)
      expect(page).to have_css('.field-group.sender_name', visible: false)
    end
  end

  def have_visible_advanced_search_controls
    have_css('.container.advanced-search', visible: true)
  end

end
