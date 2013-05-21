module PsuedoModel
  def self.included(base)
    base.extend ActiveModel::Naming
    base.send(:include, ActiveModel::Validations)
  end

  attr_reader :to_key

  def persisted?; end

end
