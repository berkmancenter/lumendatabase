module DefaultNameOriginal
  def self.included(model)
    model.instance_eval do
      model.send(:after_initialize, :set_name_original, if: :new_record?)
    end
  end

  def set_name_original
    self.name_original = name if self.name_original.nil?
  end

  #TODO: Remove this once a copying script has been added and run.
  def name
    if super
      super
    else
      name_original
    end
  end
end