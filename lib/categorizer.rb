module Categorizer
  def categorizes(model, options = {})
    belongs_to model, options
    belongs_to :category

    validates_uniqueness_of :category_id, scope: :"#{model}_id"
  end
end
