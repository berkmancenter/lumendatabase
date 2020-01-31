class CollapsesTopics

  def initialize(from, to)
    @from = Topic.find_by_name(from)
    @to = Topic.find_by_name(to)
  end

  MODELS = %w|
    TopicManager
    RelevantQuestion
    Notice
  |

  def collapse
    MODELS.map(&:constantize).each do |model|
      to_remove = model.select("#{model.to_s.tableize}.*").joins(:topics).where("topic_id = ?", @from.id)
      to_remove.each do |instance|
        instance.topics.delete(@from)
        instance.topic_ids << @to.id
        instance.save
      end
    end

    @from.destroy
  end

end
