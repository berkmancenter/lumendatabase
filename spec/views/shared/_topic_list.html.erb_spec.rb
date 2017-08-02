require 'rails_helper'

describe 'shared/_topic_list.html.erb' do
  it "includes links to each topic by name" do
    topics = build_stubbed_list(:topic, 3)

    render 'shared/topic_list', topics: topics

    topics.each do |topic|
      expect(rendered).to contain_link(topic_path(topic), topic.name)
    end
  end

  it "builds the comma-separated list correctly" do
    topics = build_stubbed_list(:topic, 3)

    render 'shared/topic_list', topics: topics

    expect(rendered).to have_content(/^#{topics.map(&:name).join(', ')}$/)
  end
end
