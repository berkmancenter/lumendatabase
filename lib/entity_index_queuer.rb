class EntityIndexQueuer
  def self.for(entity_id)
    Notice.joins(:entity_notice_roles).where(
      'entity_notice_roles.entity_id = ?', entity_id
    ).update_all(['updated_at = ?', Time.now])
  end
end
