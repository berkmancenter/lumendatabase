module DefaultUrlOriginal
  def self.included(model)
    model.instance_eval do
      model.send(:after_initialize, :set_url_original, if: :new_record?)
    end
  end

  def set_url_original
    self.url_original = url if self.url_original.nil?
  end
end
