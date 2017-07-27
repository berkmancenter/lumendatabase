require 'rails_helper'

describe 'shared/_navigation.html.erb' do
  it 'shows a link to create a new notice' do
    render

    expect(rendered).to contain_link(new_notice_path)
  end

  it 'shows a link to read the blog' do
    render

    expect(rendered).to contain_link(blog_entries_path)
  end

  it 'shows a link to research' do
    render

    expect(rendered).to contain_link(page_path("research"))
  end

  it 'has links to all topics' do
    topics = create_list(:topic, 3)

    render

    topics.each do |topic|
      expect(rendered).to contain_link(topic_path(topic))
    end
  end

  it 'shows topics in alphabetical order' do
    first_topic = create(:topic, name: 'AA topic')
    third_topic = create(:topic, name: 'CC topic')
    second_topic = create(:topic, name: 'BB topic')

    render

    expect(rendered).to have_css('#dropdown-topics li:nth-child(1)', text: first_topic.name)
    expect(rendered).to have_css('#dropdown-topics li:nth-child(2)', text: second_topic.name)
    expect(rendered).to have_css('#dropdown-topics li:nth-child(3)', text: third_topic.name)
  end
end
