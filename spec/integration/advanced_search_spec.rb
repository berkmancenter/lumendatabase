require 'spec_helper'

feature "Advanced search", search: true do
  before do
    enable_live_searches
  end

  context 'facets' do
    it 'on submitter names' do
      notice = create(:notice, :with_facet_data)
      with_a_facetted_search(
        :submitter_name, :submitter_name_facet) do |results|
        expect(results).to have_facets('submitter_name').
          with_terms([notice.submitter_name])
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
          with_terms(notice.categories.map(&:name).uniq)
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
