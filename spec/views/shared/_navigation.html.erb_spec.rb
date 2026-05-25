require 'rails_helper'

describe 'shared/_navigation.html.erb' do
  include Comfy::ComfyHelper

  it 'shows client links in the client area' do
    allow(view).to receive(:client_navigation?).and_return(true)
    allow(view).to receive(:client_my_notices_path)
      .and_return(client_notices_search_index_path(sort_by: 'created_at desc'))

    render

    expect(rendered).to contain_link(
      client_notices_search_index_path(sort_by: 'created_at desc'),
      'My notices'
    )
    expect(rendered).to contain_link(client_settings_path)
    expect(rendered).to contain_link(destroy_user_session_path)
    expect(rendered).to have_css('.main-nav .nav-item:nth-child(1)', text: 'My notices')
    expect(rendered).to have_css('.main-nav .nav-item:nth-child(2)', text: 'Settings')
    expect(rendered).not_to include(Translation.t('navigation_header_search'))
    expect(rendered).not_to include(Translation.t('navigation_header_topics'))
    expect(rendered).not_to include(Translation.t('navigation_header_media_mentions'))
  end

  it 'has links to all topics' do
    allow(view).to receive(:client_navigation?).and_return(false)
    topics = create_list(:topic, 3)

    render

    topics.each do |topic|
      expect(rendered).to contain_link(topic_path(topic))
    end
  end

  it 'shows topics in alphabetical order' do
    allow(view).to receive(:client_navigation?).and_return(false)
    first_topic = create(:topic, name: 'AA topic')
    third_topic = create(:topic, name: 'CC topic')
    second_topic = create(:topic, name: 'BB topic')

    render

    expect(rendered).to have_css('#dropdown-topics li:nth-child(1)', text: first_topic.name)
    expect(rendered).to have_css('#dropdown-topics li:nth-child(2)', text: second_topic.name)
    expect(rendered).to have_css('#dropdown-topics li:nth-child(3)', text: third_topic.name)
  end
end
