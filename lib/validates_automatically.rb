module ValidatesAutomatically

  def self.included(model)
    model.instance_eval do
      to_validate = self.columns.reject{|col| ! [:string,:text].include?(col.type)}
      to_validate.each do|column_to_validate|
        validations = {}

        if column_to_validate.null == false
          validations[:presence] = true
        end

        if column_to_validate.limit
          validations[:length] = { maximum: column_to_validate.limit }
        end

        if validations.present?
          validation_attributes = [column_to_validate.name, validations]
          model.send(:validates, *validation_attributes )
        end
      end
    end

  end

end
