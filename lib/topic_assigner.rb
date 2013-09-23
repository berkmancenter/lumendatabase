module TopicAssigner
  def assigns_topic_to(model, options = {})
    belongs_to model, options
    belongs_to :topic

    validates_uniqueness_of :topic_id, scope: :"#{model}_id"
  end
end
