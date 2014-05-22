class TopicIndexQueuer
  def self.for(topic_id)
    Notice.joins(:topic_assignments).where(
      'topic_assignments.topic_id = ?', topic_id
    ).update_all(['updated_at = ?', Time.now])
  end
end
