require 'rails_helper'

feature 'Fielded searches of Notices' do
  include SearchHelpers

  ADVANCED_SEARCH_FIELDS = Notice::SEARCHABLE_FIELDS.reject do |field|
    field.parameter == :term
  end

  context 'via parameters only' do
    ADVANCED_SEARCH_FIELDS.each do |field|
      scenario "within #{field.title}", search: true do
        generator = FieldedSearchNoticeGenerator.for(field)
        index_changed_instances

        search_on_page = FieldedSearchOnPage.new
        search_on_page.parameterized_search_for(field.parameter, generator.query)

        search_on_page.within_results do
          expect(page).to have_words(generator.matched_notice.title)
          expect(page).to have_no_content(generator.unmatched_notice.title)
        end
      end
    end
  end

  context 'via the web UI' do
    ADVANCED_SEARCH_FIELDS.each do |field|
      scenario "within #{field.title}", search: true, js: true do
        generator = FieldedSearchNoticeGenerator.for(field)
        index_changed_instances

        search_on_page = FieldedSearchOnPage.new
        search_on_page.visit_search_page
        search_on_page.add_fielded_search_for(field, generator.query)

        search_on_page.run_search

        search_on_page.within_results do
          expect(page).to have_words(generator.matched_notice.title)
          expect(page).to have_no_content(generator.unmatched_notice.title)
        end
      end
    end
  end

  scenario 'searches can be limited to all words in a term', search: true, js: true do
    outside_search = create(:dmca, title: 'King of New York')
    inside_search = create(:dmca, :with_facet_data, title: 'Lion King two')
    index_changed_instances

    field = TermSearch.new(:title, :title, 'Title')
    search_on_page = FieldedSearchOnPage.new
    search_on_page.visit_search_page

    search_on_page.add_fielded_search_for(field, 'Lion King')
    search_on_page.limit_search_to_all_words_for(field)

    search_on_page.run_search

    search_on_page.within_results do
      expect(page).to have_words(inside_search.title)
      expect(page).to have_no_content(outside_search.title)
    end

    within('.field-group.title') do
      expect(page).to have_css('input[type="checkbox"]:checked')
    end
  end

  context 'sorting by date_received' do
    before do
      @notice_new_received = create(:dmca, title: 'Lion King', date_received: 1.day.ago)
      @notice_old_received = create(
        :dmca, title: 'King Leon', date_received: 10.days.ago
      )

      index_changed_instances

      submit_search('king')
    end

    scenario 'by newest date_received', search: true, js: true do
      search_on_page = FieldedSearchOnPage.new
      search_on_page.define_sort_order('date_received desc')

      expect(page).to have_sort_order_selection_of('Date Received - newest')
      search_on_page.within_results do
        expect(page).to have_first_notice_of(@notice_new_received)
        expect(page).to have_last_notice_of(@notice_old_received)
      end
    end

    scenario 'by oldest date_received', search: true, js: true do
      search_on_page = FieldedSearchOnPage.new
      search_on_page.define_sort_order('date_received asc')

      expect(page).to have_sort_order_selection_of('Date Received - oldest')
      search_on_page.within_results do
        expect(page).to have_first_notice_of(@notice_old_received)
        expect(page).to have_last_notice_of(@notice_new_received)
      end
    end
  end

  context 'sorting by created_at' do
    before do
      @notice_old_created = create(:dmca, title: 'King Leon')
      @notice_new_created = create(:dmca, title: 'Lion King')

      index_changed_instances

      submit_search('king')
    end

    scenario 'by newest created_at', search: true, js: true do
      search_on_page = FieldedSearchOnPage.new
      search_on_page.define_sort_order('created_at desc')

      expect(page).to have_sort_order_selection_of('Reported to Lumen - newest')
      search_on_page.within_results do
        expect(page).to have_first_notice_of(@notice_new_created)
        expect(page).to have_last_notice_of(@notice_old_created)
      end
    end

    scenario 'by oldest created_at', search: true, js: true do
      search_on_page = FieldedSearchOnPage.new
      search_on_page.define_sort_order('created_at asc')

      expect(page).to have_sort_order_selection_of('Reported to Lumen - oldest')
      search_on_page.within_results do
        expect(page).to have_first_notice_of(@notice_old_created)
        expect(page).to have_last_notice_of(@notice_new_created)
      end
    end
  end

  context 'advanced search' do
    scenario 'is open when a faceted search is run', search: true, js: true do
      notice = create(:dmca, :with_facet_data, title: 'Lion King')
      index_changed_instances

      visit "/faceted_search?sender_name=#{CGI.escape(notice.sender_name)}"

      expect(page).to have_visible_advanced_search_controls
    end

    scenario 'copies search parameters to the facet form.', search: true, js: true, cache: true do
      notice = create(:dmca, :with_facet_data, title: 'Lion King two')
      index_changed_instances

      search_on_page = FieldedSearchOnPage.new
      search_on_page.visit_search_page(true)
      search_on_page.open_advanced_search

      search_on_page.add_fielded_search_for(title_field, 'lion')

      expect(page).to have_css(".field-group.#{title_field.parameter}")

      open_and_select_facet(:sender_name_facet, notice.sender_name)

      expect(page).to have_active_facet(:sender_name_facet, notice.sender_name)
      expect(page).to have_n_results 1
      search_on_page.within_fielded_searches do
        expect(page).to have_css('input[value="lion"]')
      end
    end

    context 'not active' do
      scenario 'dropdown not displayed by default', search: true, js: true do
        search_on_page = FieldedSearchOnPage.new
        search_on_page.visit_search_page

        expect(page).to have_no_visible_advanced_search_controls
      end
    end

    context 'active' do
      before :each do
        search_on_page = FieldedSearchOnPage.new
        search_on_page.visit_search_page
        search_on_page.open_advanced_search
      end

      scenario 'dropdown retains visibility between page views', search: true, js: true do
        search_on_page = FieldedSearchOnPage.new
        search_on_page.open_advanced_search
        expect(page).to have_visible_advanced_search_controls

        sleep 0.2

        search_on_page.visit_search_page
        expect(page).to have_visible_advanced_search_controls
      end

      scenario 'retains query parameters', search: true, js: true do
        search_on_page = FieldedSearchOnPage.new
        search_on_page.add_fielded_search_for(title_field, 'lion')

        search_on_page.run_search(false)
        search_on_page.open_advanced_search

        search_on_page.within_fielded_searches do
          expect(page).to have_css('.field-group.title')
          expect(page).to have_no_css('.field-group.sender_name')
        end
      end

      scenario 'attempted injection via query parameters', search: true, js: true do
        # <input value='                                          '/>
        attack =       "'/><div id='inserted'></div><input value='"

        search_on_page = FieldedSearchOnPage.new
        search_on_page.parameterized_search_for(:title, attack)

        search_on_page.within_fielded_searches do
          expect(page).to have_no_css('div#inserted')
        end
      end

      scenario 'allows you to remove a fielded search', search: true, js: true do
        search_on_page = FieldedSearchOnPage.new
        search_on_page.add_fielded_search_for(title_field, 'lion')

        search_on_page.remove_fielded_search_for(:title)

        search_on_page.within_fielded_searches do
          expect(page).to have_no_fielded_search_for(:title)
        end
      end

      scenario 'does not allow changing a field after adding another', search: true, js: true do
        search_on_page = FieldedSearchOnPage.new
        search_on_page.add_fielded_search_for(title_field, 'lion')
        search_on_page.add_more

        within('.field-group.title') do
          expect(page).to have_no_select('search-field')
        end
      end

      scenario 'removes the option from other drop-downs for a search that\'s been added', search: true, js: true do
        search_on_page = FieldedSearchOnPage.new
        search_on_page.add_fielded_search_for(title_field, 'lion')
        search_on_page.add_more

        search_on_page.within_fielded_searches do
          # existing field is made disabled, and the new select should
          # not have Title as an option
          expect(page).to have_no_select(
            'search-field', with_options: ['Title']
          )
        end
      end

      scenario 'removes the options for a search from a previous page', search: true, js: true do
        search_on_page = FieldedSearchOnPage.new
        search_on_page.add_fielded_search_for(title_field, 'lion')
        search_on_page.run_search(false)

        search_on_page.within_fielded_searches do
          # existing field is made disabled, and the new select should
          # not have Title as an option
          expect(page).to have_no_select(
            'search-field', with_options: ['Title']
          )
        end
      end

      scenario 'allows you to select a search after you delete it', search: true, js: true do
        search_on_page = FieldedSearchOnPage.new
        search_on_page.add_fielded_search_for(title_field, 'lion')
        search_on_page.remove_fielded_search_for(:title)

        search_on_page.add_fielded_search_for(title_field, 'lion')

        search_on_page.within_fielded_searches do
          expect(page).to have_select(
            'search-field', with_options: ['Title'], count: 1
          )
        end
      end

      scenario 'does not allow you to select the same search twice', search: true, js: true do
        search_on_page = FieldedSearchOnPage.new
        search_on_page.add_fielded_search_for(title_field, 'lion')

        search_on_page.within_fielded_searches do
          expect(page).to have_select(
            'search-field', with_options: ['Title'], count: 1
          )
        end
      end

      scenario 'removes the add query link after all searches have been added', search: true, js: true do
        search_on_page = FieldedSearchOnPage.new
        Notice::SEARCHABLE_FIELDS.each do |field|
          search_on_page.add_fielded_search_for(field, 'test')
          expect(page).to have_css(".field-group.#{field.parameter}")
        end

        search_on_page.within_fielded_searches do
          skip "It's not worth debugging this line's intermittent failures"
          expect(page).to have_no_css('#duplicate-field')
        end
      end

      scenario 'activates the add query link when they are available', search: true, js: true do
        search_on_page = FieldedSearchOnPage.new
        Notice::SEARCHABLE_FIELDS.each do |field|
          search_on_page.add_fielded_search_for(field, 'test')
          skip "It's not worth debugging this line's intermittent failures"
          expect(page).to have_css(".field-group.#{field.parameter}")
        end

        search_on_page.remove_fielded_search_for(:title)

        search_on_page.within_fielded_searches do
          expect(page).to have_css('#duplicate-field')
        end
      end
    end
  end

  private

  def have_visible_advanced_search_controls
    have_css('.container.advanced-search', visible: true)
  end

  def have_no_visible_advanced_search_controls
    have_css('.container.advanced-search', visible: false)
  end

  def have_fielded_search_for(parameter)
    have_css(".field-group.#{parameter}", visible: true)
  end

  def have_no_fielded_search_for(parameter)
    have_no_css(".field-group.#{parameter}", visible: true)
  end

  def have_first_notice_of(notice)
    have_css("ol.results-list li:first-child[id='notice_#{notice.id}']")
  end

  def have_last_notice_of(notice)
    have_css("ol.results-list li:last-child[id='notice_#{notice.id}']")
  end

  def have_sort_order_selection_of(sort_by)
    have_css('.sort-order a.dropdown-toggle', text: sort_by)
  end

  def title_field
    Notice::SEARCHABLE_FIELDS.detect { |field| field.parameter == :title }
  end
end
