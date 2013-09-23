require 'spec_helper'
require 'collapses_topics'

describe CollapsesTopics do
  [BlogEntry, TopicManager, RelevantQuestion, Notice].each do |model|
    it "correctly merges a set of topics together for #{model.name}" do
      factory_name = singular_name = model.name.tableize.singularize
      if singular_name == 'notice'
        factory_name = 'dmca'
      end
      from_topic = create(:topic, name: 'Topic to remove')
      to_topic = create(:topic, name: 'Topic to merge into')
      other_topic = create(:topic)

      2.times do
        create(factory_name, topics: [from_topic, to_topic, other_topic])
      end

      collapser = CollapsesTopics.new(from_topic.name, to_topic.name)
      collapser.collapse

      expect(Topic.find_by_name(from_topic.name)).to be_nil
      expect(to_topic.send("#{singular_name}_ids")).to match_array(model.all.map(&:id))
      expect(other_topic.send("#{singular_name}_ids")).to match_array(model.all.map(&:id))
      expect(from_topic.notice_ids).to be_empty
    end
  end
end
