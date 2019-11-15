require 'rails_helper'

feature 'Faceted search of Notices', search: true do
  include SearchHelpers

  context 'filtering with a full-text search term' do
    %i[
      topic_facet
      sender_name_facet
      principal_name_facet
      recipient_name_facet
      tag_list_facet
      country_code_facet
      language_facet
      action_taken_facet
    ].each do |facet_type|
      it "on #{facet_type}", js: true, search: true do
        _outside_facet = create(:dmca, title: 'King of New York')
        inside_facet = create(:dmca, :with_facet_data, title: 'Lion King two')
        inside_facet.entities.update_all(country_code: 'BH')
        index_changed_instances

        within_search_results_for('king') do
          expect(page).to have_n_results 2
        end

        facet = if facet_type == :topic_facet
                  inside_facet.topics.first.name
                elsif facet_type == :tag_list_facet
                  inside_facet.tags.first.name
                elsif facet_type == :country_code_facet
                  'BH'
                else
                  inside_facet.send(facet_type.to_s.gsub(/_facet/, '').to_sym)
                end

        within_faceted_search_results_for('king', facet_type, facet) do
          expect(page).to have_active_facet_dropdown(facet_type)
          expect(page).to have_active_facet(facet_type, facet)
          expect(page).to have_n_results 1
          expect(page).to have_words(inside_facet.title)
        end

        expect(page).to have_css("input#search[value='king']")
      end
    end

    it 'on date ranges', js: true, search: true do
      _outside_facet = create(
        :dmca, title: 'A title', date_received: Time.now - 10.months
      )
      inside_facet = create(
        :dmca, title: 'A title', date_received: Time.now - 1.day
      )
      index_changed_instances

      within_search_results_for('title') do
        expect(page).to have_n_results 2
      end

      open_dropdown_for_facet('date_received_facet')
      facet = page.find('ol.date_received_facet li:nth-child(3)').text

      within_faceted_search_results_for('title', :date_received_facet, facet) do
        expect(page).to have_active_facet_dropdown(:date_received_facet)
        expect(page).to have_n_results 1
        expect(page).to have_words(inside_facet.title)
      end
    end
  end

  context 'facet auto-submission' do
    scenario 'a user selects a facet', js: true, search: true do
      create(:dmca, title: 'Lion King', date_received: 10.months.ago)
      notice = create(:dmca, title: 'King Leon', date_received: 1.day.ago)
      index_changed_instances

      within_search_results_for('king') do
        expect(page).to have_n_results 2
      end

      click_on 'Date'
      find('ol.date_received_facet li:nth-child(3) a').click

      expect(page).to have_active_facet_dropdown(:date_received_facet)
      expect(page).to have_n_results 1
      expect(page).to have_words(notice.title)
    end
  end
end
