require 'spec_helper'

feature "Faceted search of Notices", search: true do
  include SearchHelpers

  context 'facets' do
    it 'on sender names', search: true do
      notice = create(:dmca, :with_facet_data)
      with_a_faceted_search(
        :sender_name, :sender_name_facet) do |results|
        expect(results).to have_facets('sender_name').
          with_terms([notice.sender_name])
      end
    end

    it 'on tags', search: true do
      notice = create(:dmca, :with_facet_data)
      with_a_faceted_search(
        :tags, :tag_list_facet) do |results|
        expect(results).to have_facets('tags').
          with_terms(notice.tag_list)
      end
    end

    it 'on jurisdictions', search: true do
      notice = create(:dmca, :with_facet_data)
      with_a_faceted_search(
        :jurisdiction, :jurisdiction_list_facet) do |results|
        expect(results).to have_facets('jurisdiction').
          with_terms(notice.jurisdiction_list)
      end
    end

    it 'on country', search: true do
      notice = create(:dmca, :with_facet_data)
      with_a_faceted_search(
        :country_code, :country_code_facet) do |results|
        expect(results).to have_facets('country_code').
          with_terms([notice.country_code])
      end
    end

    it 'on recipient names', search: true do
      notice = create(:dmca, :with_facet_data)
      with_a_faceted_search(
        :recipient_name, :recipient_name_facet) do |results|
        expect(results).to have_facets('recipient_name').
          with_terms([notice.recipient_name])
      end
    end

    it 'on topics', search: true do
      notice = create(:dmca, :with_facet_data)
      with_a_faceted_search(
        :topics, :topic_facet) do |results|
        expect(results).to have_facets('topics').
          with_terms(notice.topics.map(&:name))
      end
    end

    it 'on date_received', search: true do
      notice = create(:dmca, :with_facet_data)
      sleep 1

      results = Notice.search do
        query { match(:_all, 'title') }
        facet :date_received do
          range :date_received, [
            { from: Time.now - 1.day, to: Time.now }
          ]
        end
      end
      expect(results.facets['date_received']['ranges'].length).to eq 1
      expect(results.facets['date_received']['ranges'].first['count']).
        to eq 1
    end
  end

  context "filtering" do
    context "with a full-text search term" do
      [
        :topic_facet, :sender_name_facet, :recipient_name_facet, :tag_list_facet, :country_code_facet
      ].each do |facet_type|
        it "on #{facet_type}", js: true, search: true do
          outside_facet = create(:dmca, title: "King of New York")
          inside_facet = create(:dmca, :with_facet_data, title: "Lion King two")

          within_search_results_for('king') do
            expect(page).to have_n_results 2
          end

          facet = ''
          if facet_type == :topic_facet
            facet = inside_facet.topics.first.name
          elsif facet_type == :tag_list_facet
            facet = inside_facet.tags.first
          else
            facet = inside_facet.send(facet_type.to_s.gsub(/_facet/, '').to_sym)
          end

          within_faceted_search_results_for("king", facet_type, facet) do
            expect(page).to have_active_facet_dropdown(facet_type)
            expect(page).to have_active_facet(facet_type, facet)
            expect(page).to have_n_results 1
            expect(page).to have_content(inside_facet.title)
          end

          expect(page).to have_css("input#search[value='king']")
        end
      end

      it "on date ranges", js: true, search: true do
        outside_facet = create(
          :dmca, title: 'A title', date_received: Time.now - 10.months
        )
        inside_facet = create(
          :dmca, title: 'A title', date_received: Time.now - 1.day
        )
        within_search_results_for('title') do
          expect(page).to have_n_results 2
        end

        open_dropdown_for_facet('date_received_facet')
        facet = page.find('ol.date_received_facet li:nth-child(2)').text

        within_faceted_search_results_for("title", :date_received_facet, facet) do
          expect(page).to have_active_facet_dropdown(:date_received_facet)
          expect(page).to have_n_results 1
          expect(page).to have_content(inside_facet.title)
        end
      end
    end
  end

  context "facet auto-submission" do
    scenario "a user selects a facet", js: true, search: true do
      create(:dmca, title: "Lion King", date_received: 10.months.ago)
      notice = create(:dmca, title: "King Leon", date_received: 1.day.ago)

      within_search_results_for('king') do
        expect(page).to have_n_results 2
      end

      click_on 'Date'
      find('ol.date_received_facet li:nth-child(2) a').click

      expect(page).to have_active_facet_dropdown(:date_received_facet)
      expect(page).to have_n_results 1
      expect(page).to have_content(notice.title)
    end
  end

  def with_a_faceted_search(facet_name, facet_attribute_name)
    sleep 1
    results = Notice.search do
      query { match(:_all, 'title') }
      facet facet_name do
        terms facet_attribute_name, size: 10
      end
    end
    yield results
  end
end
