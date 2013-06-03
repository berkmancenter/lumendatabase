class NormalizesParameters

  def self.normalize(params)
    @params = params
    if has_works_parameters?
      works_parameters.each do |work_param_hash|
        work_param_hash[:infringing_urls] =
          work_param_hash[:infringing_urls].split(/\r?\n/)
      end
    end
  end

  private

  def self.has_works_parameters?
    works_parameters
  end

  def self.works_parameters
    @params[:submission][:works]
  end
end
