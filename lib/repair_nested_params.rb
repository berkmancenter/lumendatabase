module RepairNestedParams
  def repair_nested_params(obj)
    obj.each do |key, value|
      if value.is_a?(ActionController::Parameters) || value.is_a?(Hash)
        # If any non-integer keys
        if value.keys.find { |k, _| k =~ /\D/ }
          repair_nested_params(value)
        else
          obj[key] = value.values
          value.values.each { |h| repair_nested_params(h) }
        end
      end
    end
  end
end
