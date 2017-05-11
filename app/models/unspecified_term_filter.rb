class UnspecifiedTermFilter < TermFilter
  def self.unspecified_identifier(p)
    "#{p}_unspecified"
  end

  def unspecified_param
    @unspecified_param ||= self.class.unspecified_identifier(parameter).to_sym
  end

  def apply_to_search(searcher, param, value)
    if handles?(param)
      if unspecified_param?(param)
        unspecified_filter(searcher)
      else
        super
      end
    end
  end

  private

  def handles?(parameter_of_concern)
    parameter == parameter_of_concern.to_sym || unspecified_param?(parameter_of_concern)
  end

  def unspecified_param?(parameter_of_concern)
    unspecified_param == parameter_of_concern.to_sym
  end

  def unspecified_filter(searcher)
    searcher.filter(
      :bool,
      should: [
        { terms: { @indexed_attribute => [''] } },
        { missing: { field: @indexed_attribute } }
      ]
    )
  end
end
