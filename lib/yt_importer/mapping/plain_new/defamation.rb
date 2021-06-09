require 'yt_importer/mapping/plain_new/base'

module YtImporter
  module Mapping
    module PlainNew
      class Defamation < Base
        NOTICE_TYPE_LABEL = 'Defamation'

        def notice_type
          ::Defamation
        end

        def jurisdiction
          get_single_line_field('country').split(',')
        end

        def local_jurisdiction_laws
          one = get_naive_multiline_field('country_law_one:', 'identify_two:')
          two = get_naive_multiline_field('country_law_two:', 'identify_three:')
          three = get_naive_multiline_field('country_law_three:', 'identify_four:')
          four = get_naive_multiline_field('country_law_four:', 'identify_five:')
          five = get_naive_multiline_field('country_law_five:', 'affirmation:')

          [one, two, three, four, five]
            .reject(&:blank?)
            .uniq
            .map.with_index { |item, index| "#{index + 1}. #{item}" }
            .join("\n")
        end

        private

        def parsed_infringing_urls
          @notice_text.scan(/videourl:\s*(.+)\n/).flatten
        end

        def work_description
          get_naive_multiline_field('identify_one:', 'where_one:')
        end

        def sender
          behalf_client = get_single_line_field('behalf_client')
          signature = get_single_line_field('Signature')
          country_code = get_single_line_field('country')

          name = signature if signature.present?
          name = behalf_client if behalf_client.present?
          if country_code.present?
            address = {}
            address[:country_code] = country_code
          end

          return nil if name.blank?

          build_role('sender', name, address)
        end

        def principal
          behalf_client = get_single_line_field('behalf_client')
          legal_name = get_single_line_field('Fulllegalname')

          name = legal_name if legal_name.present?
          name = behalf_client if behalf_client.present?

          return nil if name.blank?

          build_role('principal', name)
        end
      end
    end
  end
end
