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

  context "advanced search" do
    it "copies search parameters to the facet form.", js: true do
      notice = create(:notice, :with_facet_data, title: "Lion King two")
      sleep 1

      search_on_page.visit_search_page
      search_on_page.open_advanced_search

      search_on_page.add_fielded_search_for('Title', 'lion')
      open_and_select_facet(:sender_name_facet, notice.sender_name)
      click_faceted_search_button

      expect(page).to have_active_facet(:sender_name_facet, notice.sender_name)
      expect(page).to have_n_results 1
      search_on_page.within_fielded_searches do
        expect(page).to have_css('input[value="lion"]')
      end
    end

    context "not active" do
      it "dropdown not displayed by default", js: true do
        search_on_page = FieldedSearchOnPage.new
        search_on_page.visit_search_page

        expect(page).not_to have_visible_advanced_search_controls
      end
    end

    context "active" do
      before :each do
        search_on_page.visit_search_page
        search_on_page.open_advanced_search
      end

      it "dropdown retains visibility between page views", js: true do
        pending 'Javascript set cookies do not appear to work in capybara-webkit'

        expect(page).to have_visible_advanced_search_controls

        search_on_page.visit_search_page
        expect(page).to have_visible_advanced_search_controls
      end

      it "retains query parameters", js: true do
        search_on_page.add_fielded_search_for('Title', 'lion')

        search_on_page.run_search
        search_on_page.open_advanced_search

        search_on_page.within_fielded_searches do
          expect(page).to have_css('.field-group.title', visible: true)
          expect(page).to have_css('.field-group.sender_name', visible: false)
        end
      end

      it "allows you to remove a fielded search", js: true do
        search_on_page.add_fielded_search_for('Title', 'lion')

        search_on_page.remove_fielded_search_for(:title)

        search_on_page.within_fielded_searches do
          expect(page).to_not have_fielded_search_for(:title)
        end
      end

      it "allows you to change a fielded search", js: true do
        search_on_page.add_fielded_search_for('Title', 'lion')
        search_on_page.change_field(:title, 'Tags')

        search_on_page.within_fielded_searches do
          expect(page).to have_css("input[name='tags']")
          expect(page).to have_select(
            'search-field', with_options: ['Tags'], count: 1
          )
        end
        search_on_page.within_template_row do
          expect(page).to have_select(
            'search-field', with_options: ['Title'], count: 1
          )
        end
      end

      it "removes the option from other drop-downs for a search that's been added", js: true do
        search_on_page.add_fielded_search_for('Title', 'lion')

        search_on_page.within_fielded_searches do
          expect(page).to have_select(
            'search-field', with_options: ['Title'], count: 1
          )
        end
      end

      it "removes the options for a search from a previous page", js: true do
        search_on_page.add_fielded_search_for('Title', 'lion')
        search_on_page.run_search

        search_on_page.within_fielded_searches do
          expect(page).to have_select(
            'search-field', with_options: ['Title'], count: 1
          )
        end
      end

      it "allows you to select a search after you delete it", js: true do
        search_on_page.add_fielded_search_for('Title', 'lion')
        search_on_page.remove_fielded_search_for(:title)

        search_on_page.add_fielded_search_for('Title', 'lion')

        search_on_page.within_fielded_searches do
          expect(page).to have_select(
            'search-field', with_options: ['Title'], count: 1
          )
        end
      end

      it "does not allow you to select the same search twice", js: true do
        search_on_page.add_fielded_search_for('Title', 'lion')

        search_on_page.within_template_row do
          expect(page).to have_select(
            'search-field', with_options: ['Title'], count: 0
          )
        end
        search_on_page.within_fielded_searches do
          expect(page).to have_select(
            'search-field', with_options: ['Title'], count: 1
          )
        end
      end

      it "removes the add query link after all searches have been added", js: true do
        Notice::SEARCHABLE_FIELDS.each do |field|
          search_on_page.add_fielded_search_for(field[:name], 'test')
        end

        search_on_page.within_fielded_searches do
          expect(page).to_not have_css('#duplicate-field')
          expect(page).to_not have_css('.template-row')
        end
      end

      it "activates the add query link when they are available", js: true do
        Notice::SEARCHABLE_FIELDS.each do |field|
          search_on_page.add_fielded_search_for(field[:name], 'test')
        end

        search_on_page.remove_fielded_search_for(:title)

        search_on_page.within_fielded_searches do
          expect(page).to have_css('#duplicate-field')
        end
        search_on_page.within_template_row do
          expect(page).to have_select(
            'search-field', with_options: ['Title'], count: 1
          )
        end
      end


    end
  end

  def have_visible_advanced_search_controls
    have_css('.container.advanced-search', visible: true)
  end

  def have_fielded_search_for(parameter)
    have_css(".field-group.#{parameter}", visible: true)
  end

  def search_on_page
    @search_on_page ||= FieldedSearchOnPage.new
  end

end
