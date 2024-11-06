require 'loggy'
require 'github_importer/mapping/dmca'

module GithubImporter
  class GithubImporter
    REPO = 'dmca'
    REPO_OWNER = 'github'

    def initialize
      @logger = Loggy.new('GithubImporter', true, true)
      @number_to_import = 0
      @number_imported = 0
      @number_failed_imports = 0
      @github_token = LumenSetting.get('github_api_token')
    end

    def import
      start_date = import_date_from
      page = 1

      loop do
        commits = fetch_commits(start_date, page)
        break if commits.empty?

        unique_commit_shas = extract_unique_commit_shas(commits)
        process_commits(unique_commit_shas)

        page += 1
      end
    end

    private

    def fetch_commits(start_date, page)
      uri = URI("https://api.github.com/repos/#{REPO_OWNER}/#{REPO}/commits")
      uri.query = URI.encode_www_form(since: start_date, per_page: 100, page: page)
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{@github_token}"

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
      JSON.parse(response.body)
    end

    def extract_unique_commit_shas(commits)
      commits
        .select { |commit| commit['commit']['message'].match(/^Merge/) }
        .map { |commit| commit['sha'] }
    end

    def process_commits(commit_shas)
      commit_shas.each do |sha|
        import_single_commit(sha)
      end
    end

    # Format YYYY-MM-DDT00:00:00Z
    def import_date_from
      ENV['GH_IMPORT_DATE_FROM'] || DateTime.yesterday.iso8601
    end

    # For single commit sha, fetch the file contents and convert that to a notice in our DB
    def import_single_commit(sha_to_process)
      @logger.info("Importing --- #{@number_imported} imported #{@number_failed_imports} failed ---")
      @logger.info("Importing https://github.com/github/dmca/commit/#{sha_to_process}")

      uri = URI("https://api.github.com/repos/#{REPO_OWNER}/#{REPO}/commits/#{sha_to_process}")
      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = "Bearer #{@github_token}"
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end
      res_json = JSON.parse(res.read_body)
      commit_file = res_json["files"][0]
      commit_time = res_json["commit"]["author"]["date"]

      # Some commits just rename files, so we can skip those
      return unless commit_file['patch']

      # Skip if already imported
      filename = commit_file['filename']
      filename_without_dir = filename.split('/').last
      existing_file = FileUpload.where(file_file_name: filename_without_dir).first
      if existing_file.present?
        return if existing_file.notice.entity_notice_roles.where(name: 'submitter').first&.entity&.users&.first&.email == LumenSetting.get('github_user_email')
      end

      mapped_notice_data = Mapping::DMCA.new(commit_file)

      notice_params = {
        title: mapped_notice_data.title,
        subject: mapped_notice_data.subject,
        source: mapped_notice_data.source,
        tag_list: mapped_notice_data.tag_list,
        action_taken: mapped_notice_data.action_taken,
        created_at: commit_time,
        updated_at: commit_time,
        date_sent: mapped_notice_data.date_sent,
        date_received: commit_time,
        file_uploads: mapped_notice_data.file_uploads,
        works: mapped_notice_data.works,
        review_required: false,
        topics: mapped_notice_data.topics,
        rescinded: false,
        hidden: false,
        entity_notice_roles: mapped_notice_data.entity_notice_roles,
        body: mapped_notice_data.body,
        body_original: mapped_notice_data.body_original,
        mark_registration_number: mapped_notice_data.mark_registration_number,
        jurisdiction_list: mapped_notice_data.jurisdiction,
        regulation_list: mapped_notice_data.regulation_list,
        language: mapped_notice_data.language,
        local_jurisdiction_laws: mapped_notice_data.local_jurisdiction_laws
      }

      new_notice = NoticeBuilder.new(
        mapped_notice_data.notice_type, notice_params
      ).build
      new_notice.save!

      new_notice.reload.id
      new_notice.submission_id = new_notice.id
      new_notice.original_notice_id = new_notice.id
      new_notice.save!

      @number_imported += 1
    rescue StandardError, NameError => e
      @number_failed_imports += 1
      @logger.error("#{e.backtrace}: #{e.message} (#{e.class}) [#{sha_to_process}]")
    end
  end
end
