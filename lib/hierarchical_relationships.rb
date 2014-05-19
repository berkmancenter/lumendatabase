module HierarchicalRelationships
  def self.included(model)
    model.instance_eval do
      has_ancestry orphan_strategy: :restrict
    end
  end

  def parent_enum
    self.class.where('id <> ?', id).map { |r| ["#{r.name} - ##{r.id}", r.id] }
  end
end
