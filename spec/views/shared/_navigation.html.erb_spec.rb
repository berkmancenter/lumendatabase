require 'spec_helper'

describe 'shared/_navigation.html.erb' do
  it 'shows a link to create a new notice' do
    render

    expect(page).to contain_link(new_notice_path)
  end

  it 'shows a link to read the blog' do
    render

    expect(page).to contain_link(blog_entries_path)
  end

  it 'has links to all topics' do
    topics = create_list(:topic, 3)

    render

    topics.each do |topic|
      expect(page).to contain_link(topic_path(topic))
    end
  end

  it 'shows topics in alphabetical order' do
    first_topic = create(:topic, name: 'AA topic')
    third_topic = create(:topic, name: 'CC topic')
    second_topic = create(:topic, name: 'BB topic')

    render

    within('#dropdown-topics ol') do
      expect(page).to have_css('li:nth-child(1)', text: first_topic.name)
      expect(page).to have_css('li:nth-child(2)', text: second_topic.name)
      expect(page).to have_css('li:nth-child(3)', text: third_topic.name)
    end
  end
end
