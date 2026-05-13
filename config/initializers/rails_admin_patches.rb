# RAILSADMIN / DEVISE 5.X COMPATIBILITY PATCH START
# ----------------------------------------------------------------------------
# ISSUE:
# ArgumentError: comparison of Integer with Proc failed in RailsAdmin::Main#edit
#
# CONTEXT:
# This error occurs when using Devise 5.x with RailsAdmin. Devise 5.x updated
# its default password length validation to use a Proc/Lambda (e.g., 6..128)
# to support dynamic configuration.
#
# RailsAdmin attempts to generate HTML attributes (like `maxlength`) for String
# and Password fields by looking up the model's validations. When it finds a
# LengthValidator, it tries to compare its own default field length (an Integer)
# with the validator's `:maximum` or `:minimum` values. Since these are now 
# Procs in Devise, Ruby raises an ArgumentError.
#
# SOLUTION:
# This patch overrides `RailsAdmin::Config::Fields::Types::String#valid_length`.
# It inspects the LengthValidator and returns `nil` for any constraint that is 
# a Proc. This prevents the comparison error while still allowing static 
# integer constraints to be used for HTML attribute generation.
#
# REFERENCE: 
# https://github.com/railsadminteam/rails_admin/issues/3711
# ----------------------------------------------------------------------------
Rails.application.config.to_prepare do
  if defined?(RailsAdmin::Config::Fields::Types::String)
    RailsAdmin::Config::Fields::Types::String.class_eval do
      def valid_length
        @valid_length ||= begin
          validator = abstract_model.model.validators_on(name).find do |v|
            v.is_a?(ActiveModel::Validations::LengthValidator)
          end
          
          if validator
            {
              minimum: (validator.options[:minimum].is_a?(Proc) ? nil : validator.options[:minimum]),
              maximum: (validator.options[:maximum].is_a?(Proc) ? nil : validator.options[:maximum]),
              is: (validator.options[:is].is_a?(Proc) ? nil : validator.options[:is])
            }
          else
            {}
          end
        end
      end
    end
  end
end
# RAILSADMIN / DEVISE 5.X COMPATIBILITY PATCH END
