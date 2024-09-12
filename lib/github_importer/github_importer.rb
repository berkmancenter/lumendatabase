require 'loggy'
require 'github_importer/mapping/dmca'

module GithubImporter
  class GithubImporter
    FILES_DIRECTORY = ENV['BASE_DIRECTORY']
    IMPORT_FILE_BATCH_SIZE = 500
    REPO = 'dmca'
    REPO_OWNER = 'github'

    def initialize
      @logger = Loggy.new('GithubImporter', true, true)
      @number_to_import = 0
      @number_imported = 0
      @number_failed_imports = 0
    end

    def import
      shas = generate_gh_new_commits_list
      import_commits(shas)
    end

    private

    # Format YYYY-MM-DDT00:00:00Z
    def import_date_from
      ENV['GH_IMPORT_DATE_FROM'] || DateTime.yesterday.iso8601
    end

    def generate_gh_new_commits_list
      start = import_date_from

      uri = URI("https://api.github.com/repos/#{REPO_OWNER}/#{REPO}/commits?since=#{start}")
      res = Net::HTTP.get_response(uri)
      res_json = JSON.parse(res.read_body)

      unique_commits = res_json.select {|x|x["commit"]["message"].match(/^Merge/)}
      commits = unique_commits.map {|x| x["sha"] }

      @number_to_import = commits.size
      @logger.info("Found #{commits.size} new commits since #{start}")
      return commits
    end

    # Import a list of github/dmca commits as notices
    def import_commits(x)
      x.each do |sha|
        import_single_commit(sha)
      end
    end

    # For single commit sha, fetch the file contents and convert that to a notice in our DB
    def import_single_commit(sha_to_process)
      @logger.info("Importing --- #{@number_imported + @number_failed_imports}/#{@number_to_import} ---")
      @logger.info("Importing https://github.com/github/dmca/commit/#{sha_to_process}")

      uri = URI("https://api.github.com/repos/#{REPO_OWNER}/#{REPO}/commits/#{sha_to_process}")
      res = Net::HTTP.get_response(uri)
      res_json = JSON.parse(res.read_body)
      commit_file = res_json["files"][0]\

      # Remove the diff chars
      content = commit_file["patch"].gsub(/(@@.*@@\n)/, '').tr('+', ' ').tr('*', '')
      filename = commit_file["filename"]
      filename_creation_time = filename[/(\d{4}-\d{2}-\d{2})/m]
      commit_time = res_json["commit"]["author"]["date"]

      mapped_notice_data = Mapping::DMCA.new(content, filename)

      notice_params = {
        title: mapped_notice_data.title,
        subject: mapped_notice_data.subject,
        source: mapped_notice_data.source,
        tag_list: mapped_notice_data.tag_list,
        action_taken: mapped_notice_data.action_taken,
        created_at: commit_time,
        updated_at: commit_time,
        date_sent: filename_creation_time,
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
