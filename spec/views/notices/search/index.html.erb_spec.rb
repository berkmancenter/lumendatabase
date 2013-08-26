require 'spec_helper'

describe 'notices/search/index.html.erb' do
  it "display the results" do
    mock_results(build_stubbed_list(:dmca, 5))

    render

    expect(page).to have_css('.result', count: 5)
  end

  it "includes facets" do
    mock_results(build_stubbed_list(:dmca, 1))

    render

    facet_data.keys.each do|facet|
      expect(page).to have_css(".#{facet} span", count: 2)
    end
  end

  it "includes the notice data" do
    notice = create(
      :dmca,
      role_names: ['recipient','sender'],
      title: 'A notice',
      date_received: Time.now,
      categories: build_list(:category, 2)
    )
    mock_results([notice])

    render

    within('.result') do
      expect(page).to have_css('.title', text: 'A notice')
      expect(page).to have_css('.sender-receiver', text: notice.recipient_name)
      expect(page).to have_css('.sender-receiver', text: notice.sender_name)
      expect(page).to have_faceted_search_role_link(:sender_name, notice)
      expect(page).to have_faceted_search_role_link(:recipient_name, notice)
      expect(page).to have_css(
        '.date-received', text: notice.date_received.to_s(:simple)
      )
      within('.category') do
        notice.categories.each do |category|
          expect(page).to have_content(category.name)
        end
      end
      expect(page).to contain_link(notice_path(notice))
    end
  end

  context 'excerpts' do
    it "includes excerpts" do
      mock_results(
        [build_stubbed(:dmca)],
        'highlight' => { 'title' => ["foo <em>bar</em> baz"] }
      )

      render

      within('.result') do
        expect(page).to have_content('foo bar baz')
      end
    end

    it 'sanatizes excerpts' do
      mock_results(
        [build_stubbed(:dmca)],
        'highlight' => { 'title' => ["<strong>foo</strong> and <em>bar</em>"] }
      )

      render

      expect(rendered).to include('foo and <em>bar</em>')
    end
  end

  private

  def mock_results(notices, options = {})
    results = notices.map { |notice| as_tire_result(notice, options) }
    results.stub(:total_entries).and_return(results.length)
    results.stub(:total_pages).and_return(1)
    results.stub(:facets).and_return(facet_data)
    assign(:results, results)
  end

  def facet_data
    {
      "sender_name_facet" => { "terms" =>
        [
          { "term" => "Mike Itten", "count" => 27 },
          { "term" => "Imak Itten", "count" => 27 }
        ]
      },
      "recipient_name_facet" => { "terms" =>
        [
          { "term" => "Twitter", "count" => 10 },
          { "term" => "Twooter", "count" => 10 }
        ]
      },
      "category_facet" => { "terms" =>
        [
          { "term" => "DMCA", "count" => 10 },
          { "term" => "DMCA Giveup", "count" => 10 }
        ]
      },
      "tag_list_facet" => { "terms" =>
        [
          { "term" => "a tag", "count" => 27 },
          { "term" => "another tag", "count" => 27 }
        ]
      },
      "country_code_facet" => { "terms" =>
        [
          { "term" => "US", "count" => 27 },
          { "term" => "CA", "count" => 27 }
        ]
      },
      "language_facet" => { "terms" =>
        [
          { "term" => "EN", "count" => 27 },
          { "term" => "SP", "count" => 27 }
        ]
      },
      "date_received_facet"=>{ "ranges"=>
        [
          { "from" => 1371583484000.0, "to" => 1371669884000.0, "count" => 1},
          { "from" => 1371583485000.0, "to" => 1371669885000.0, "count" => 1}
        ]
      },
      "action_taken_facet" => { "terms" =>
        [
          { "term" => "No", "count" => 7 },
          { "term" => "Yes", "count" => 10 },
        ]
      },
    }
  end

  def have_faceted_search_role_link(role, notice)
    have_css(%Q(a[href="#{faceted_search_path(role => notice.send(role))}"]), text: notice.send(role))
  end

end
