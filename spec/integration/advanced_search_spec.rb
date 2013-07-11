require 'spec_helper'

feature "Advanced search", search: true do
  include SearchHelpers

  before do
    enable_live_searches
  end

  context 'facets' do
    it 'on sender names' do
      notice = create(:notice, :with_facet_data)
      with_a_facetted_search(
        :sender_name, :sender_name_facet) do |results|
        expect(results).to have_facets('sender_name').
          with_terms([notice.sender_name])
      end
    end

    it 'on tags' do
      notice = create(:notice, :with_facet_data)
      with_a_facetted_search(
        :tags, :tag_list_facet) do |results|
        expect(results).to have_facets('tags').
          with_terms(notice.tag_list)
      end
    end

    it 'on country' do
      notice = create(:notice, :with_facet_data)
      with_a_facetted_search(
        :country_code, :country_code_facet) do |results|
        expect(results).to have_facets('country_code').
          with_terms([notice.country_code])
      end
    end

    it 'on recipient names' do
      notice = create(:notice, :with_facet_data)
      with_a_facetted_search(
        :recipient_name, :recipient_name_facet) do |results|
        expect(results).to have_facets('recipient_name').
          with_terms([notice.recipient_name])
      end
    end

    it 'on categories' do
      notice = create(:notice, :with_facet_data)
      with_a_facetted_search(
        :categories, :category_facet) do |results|
        expect(results).to have_facets('categories').
          with_terms(notice.categories.map(&:name))
      end
    end

    it 'on date_received' do
      notice = create(:notice, :with_facet_data)
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

    context "without a full-text search term" do
      [
        :sender_name, :recipient_name, :categories, :tags, :country_code
      ].each do |facet_type|
        it "displays #{facet_type} facet results correctly" do
          notice = create(:notice, :with_facet_data, title: "Lion King two")
          sleep 1
          facet = ''
          if facet_type == :categories
            facet = notice.categories.first.name
          elsif facet_type == :tags
            facet = notice.tag_list.first
          else
            facet = notice.send(facet_type)
          end

          visit("/facetted_search?#{facet_type}=" + URI.escape(facet))

          within('.search-results') do
            expect(page).to have_n_results 1
          end
        end
      end
    end

    context "with a full-text search term" do
      [
        :categories, :sender_name, :recipient_name, :tags, :country_code
      ].each do |facet_type|
        it "on #{facet_type}" do
          outside_facet = create(:notice, title: "King of New York")
          inside_facet = create(:notice, :with_facet_data, title: "Lion King two")

          within_search_results_for('king') do
            expect(page).to have_n_results 2
          end

          facet = ''
          if facet_type == :categories
            facet = inside_facet.categories.first.name
          elsif facet_type == :tags
            facet = inside_facet.tags.first
          else
            facet = inside_facet.send(facet_type)
          end

          within_facetted_search_results_for("king", facet_type, facet) do
            expect(page).to have_active_facet_dropdown(facet_type)
            expect(page).to have_active_facet(facet)
            expect(page).to have_n_results 1
            expect(page).to have_content(inside_facet.title)
          end
        end
      end

      it "on date ranges" do
        outside_facet = create(
          :notice, title: 'A title', date_received: Time.now - 10.months
        )
        inside_facet = create(
          :notice, title: 'A title', date_received: Time.now - 1.day
        )
        within_search_results_for('title') do
          expect(page).to have_n_results 2
        end

        facet = page.find('ol.date_received li:nth-child(1)').text

        within_facetted_search_results_for("title", :date_received, facet) do
          expect(page).to have_active_facet_dropdown(:date_received)
          expect(page).to have_n_results 1
          expect(page).to have_content(inside_facet.title)
        end
      end
    end

  end

  def have_active_facet_dropdown(facet_type)
    have_css(".dropdown.#{facet_type}.active")
  end

  def have_active_facet(facet)
    have_css('.dropdown-menu li.active a', text: /^#{facet}/)
  end

  def with_a_facetted_search(facet_name, facet_attribute_name)
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
