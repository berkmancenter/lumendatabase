require 'rails_admin/config/fields/base'
require 'rails_admin/support/datetime'

module RailsAdmin
  module Config
    module Fields
      module Types
        class Datetime < RailsAdmin::Config::Fields::Base
          CUSTOM_RA_TIMEZONE = 'Eastern Time (US & Canada)'.freeze

          # Convert to the RA custom timezone
          def value
            value_in_default_time_zone = bindings[:object].send(name)
            return nil if value_in_default_time_zone.nil?

            convert_to_timezone(
              value_in_default_time_zone,
              Rails.application.config.time_zone,
              CUSTOM_RA_TIMEZONE
            )
          end

          # Convert back to the default app timezone
          def parse_input(params)
            params[name] = parse_value(params[name]) if params[name]

            return if params[name].nil?

            params[name] = convert_to_timezone(
              params[name],
              CUSTOM_RA_TIMEZONE,
              Rails.application.config.time_zone
            )
          end

          def convert_to_timezone(datetime, from_tz, to_tz)
            time_in_old_zone = DateTime.new
                                       .in_time_zone(from_tz)
                                       .change(
                                         year: datetime.year,
                                         month: datetime.month,
                                         day: datetime.day,
                                         hour: datetime.hour,
                                         min: datetime.min,
                                         sec: datetime.sec
                                       )

            time_in_old_zone.in_time_zone(to_tz)
          end
        end
      end
    end
  end
end
