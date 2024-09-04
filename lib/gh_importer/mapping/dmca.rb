require 'gh_importer/entity_notice_role_builder'

module GithubImporter
  module Mapping
    class DMCA
      NOTICE_TYPE_LABEL = 'DMCA'
      GITHUB = 'GitHub'
      URLS_TO_IGNORE = ['https://github.com/github/dmca/blob/master/README.md#anatomy-of-a-takedown-notice).', 'https://docs.github.com/en/github/site-policy/dmca-takedown-policy#a-how-does-this-actually-work).', 'https://docs.github.com/en/articles/guide-to-submitting-a-dmca-counter-notice).']

      def initialize(notice_text, filename)
        @notice_text = notice_text
        @notice_type = DMCA
        @filename = filename
      end

      def notice_type
        ::DMCA
      end

      def title
        "Takedown Request regarding #{self.class::NOTICE_TYPE_LABEL} Complaint to Github"
      end

      def entity_notice_roles
        [
          github_entity_role('submitter'),
          github_entity_role('recipient'),
          principal
        ]
      end

      def file_uploads
        []
      end

      def mark_registration_number
        ''
      end

      def works
        works = parse_works
        return works if works.any?

        []
      end

      def subject
        'DMCA notice to GitHub'
      end

      def topics
        Topic.where(name: self.class::NOTICE_TYPE_LABEL)
      end

      def source
        'GitHub DMCA repository'
      end

      def tag_list
        ''
      end

      def action_taken
        ''
      end

      def body
        @notice_text
      end

      def body_original
        ''
      end

      def jurisdiction
        ['US']
      end

      def regulation_list
        []
      end

      def language
        return 'en'
      end

      def local_jurisdiction_laws
        ''
      end

      private

      def parse_mark_registration_number(*)
      end

      def sender(*)
      end

      def sender_address(*)
      end

      def principal(*)
        name = @filename.match(/\d{4}-\d{2}-\d{2}-(.*?)\.md/m).captures
        titleized_name = name[0].tr('-', ' ').titleize
        build_role('principal', titleized_name)
      end

      def recipient(*)
      end

      def attorney(*)
      end

      def github_entity_role(role_name)
        gh_email = LumenSetting.get('github_user_email')
        existing_entity = EntityNoticeRole.new(
          entity: User.where(email: gh_email).first,
          name: role_name
        )
        return build_role(role_name, GITHUB) if existing_entity.id.nil?
        existing_entity
      end

      def build_role(role_name, name, address = {})
        builder = EntityNoticeRoleBuilder.new(
          role_name, name, address
        )
        builder.build
      end

      def work_description
        description_text = @notice_text[/Please provide a detailed description of the original copyrighted work that has allegedly been infringed\. If possible, include a URL to where it is posted online\.(.*?)What files should be taken down/mio, 1]
        if description_text.nil?
          return @notice_text
        else
          description_text
        end
      end

      def parse_works
        infringing_url_text = @notice_text[/Please provide URLs for each file, or if the entire repository, the repository’s URL\.(.*?)Do you claim to have/mio, 1]
        if infringing_url_text.nil?
          infringing_url_text = @notice_text
        else
          infringing_url_text += @notice_text[/Each fork is a distinct repository and must be identified separately if you believe it is infringing and wish to have it taken down\.(.*?)Is the work licensed under an open source license/mio, 1] || ''
        end

        urls = URI.extract(infringing_url_text, ['http', 'https'])
        infringing_urls = urls.map do |url|
          InfringingUrl.new(url: url) if !URLS_TO_IGNORE.include?(url)
        end
        infringing_urls.compact!

        copyrighted_url_text = @notice_text[/Please provide a detailed description of the original copyrighted work that has allegedly been infringed\. If possible, include a URL to where it is posted online\.(.*?)What files should be taken down/mio, 1] || ''

        urls = URI.extract(copyrighted_url_text, ['http', 'https'])
        copyrighted_urls = urls.map do |url|
          CopyrightedUrl.new(url: url)
        end

        [
          Work.new(
            description: work_description,
            infringing_urls: infringing_urls,
            copyrighted_urls: copyrighted_urls
          )
        ]
      end
    end
  end
end
