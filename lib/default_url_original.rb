module DefaultUrlOriginal
  def self.included(model)
    model.instance_eval do
      model.send(:after_initialize, :set_url_original, if: :new_record?)
    end
  end

  def set_url_original
    self.url_original = url if self.url_original.nil?
  end

  #TODO: Remove this once a copying script has been added and run.
  def url
    if super
      super
    else
      url_original
    end
  end
end