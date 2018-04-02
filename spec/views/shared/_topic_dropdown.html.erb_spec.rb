require 'rails_helper'

describe 'shared/_topic_dropdown.html.erb' do
  it 'shows children in alphabetical order' do
    root = create(:topic, name: 'Root')
    first_topic = create(:topic, name: 'AA topic', parent: root)
    third_topic = create(:topic, name: 'CC topic', parent: root)
    second_topic = create(:topic, name: 'BB topic', parent: root)

    render 'shared/topic_dropdown', topic: root

    expect(rendered).to have_css('li:nth-child(2)', text: first_topic.name)
    expect(rendered).to have_css('li:nth-child(3)', text: second_topic.name)
    expect(rendered).to have_css('li:nth-child(4)', text: third_topic.name)
  end
end
