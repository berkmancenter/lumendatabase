module YtImporter
  class EntityNoticeRoleBuilder
    def initialize(role_name, name, address)
      @role_name = role_name
      @name = name
      @address = address
    end

    def build
      attributes = { name: clean_entity_name(@name) }

      if @address
        attributes.merge!(@address)
      end

      EntityNoticeRole.new(name: @role_name, entity_attributes: attributes)
    end

    private

    def clean_entity_name(name)
      name = name.to_s.strip
      name = get_first_line(name)
      name = remove_broken_fields(name)
      name
    end

    def get_first_line(name)
      name.split(/\r|\n/)[0]
    end

    def remove_broken_fields(name)
      name.split(/url_box/)[0]
    end

    # def address_hash(prefix)
    #   {
    #     address_line_1: @data_from_legacy_database["#{prefix}_Address1"],
    #     address_line_2: @data_from_legacy_database["#{prefix}_Address2"],
    #     city: @data_from_legacy_database["#{prefix}_City"],
    #     state: @data_from_legacy_database["#{prefix}_State"],
    #     zip: @data_from_legacy_database["#{prefix}_Zip"],
    #     country_code: parse_country_code(@data_from_legacy_database["#{prefix}_Country"])
    #   }
    # end

    def parse_country_code(country_code)
      return country_code if country_code.nil?

      country_code.strip!

      if country_code.length == 2
        country_code
      else
        mapping[country_code] || country_code[0, 2]
      end
    end

    def mapping
      {
        'United States' => 'US',
        'USA' => 'US'
      }
    end
  end
end
