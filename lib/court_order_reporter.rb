class CourtOrderReporter
  def initialize
    @loggy = Loggy.new('rake lumen:CourtOrderReporter', true)
  end

  def report
    setup_directories
    initialize_info_file
    fetch_files
    write_files
    make_archive
    email_users
  end

  def setup_directories
    @loggy.info '[rake] Generating court order attachments report'

    @magic_dir = ENV['USER_CRON_MAGIC_DIR'] || 'usercron'
    @base_dir = Rails.root.join('public', @magic_dir)
    Dir.mkdir(@base_dir) unless Dir.exist?(@base_dir)

    @working_dir = Rails.root.join('public', @magic_dir, 'working')
    Dir.mkdir(@working_dir) unless Dir.exist?(@working_dir)
  end

  def initialize_info_file
    @info_filepath = File.join(@working_dir, 'info.txt')
    info_header = <<~HEREDOC
      The following notices (if any) have attached files which must be reviewed
      by Lumen staff before they can be released:
    HEREDOC

    File.write(@info_filepath, info_header)
  end

  def fetch_files
    order_ids = if ENV['EXCLUDE_ENTITY_NAMES']
                  CourtOrder.where('notices.created_at > ?', 1.week.ago)
                            .includes(:entities)
                            .references(:entities)
                            .where.not(entities: {
                              name: ENV['EXCLUDE_ENTITY_NAMES'].split(',')
                            }).distinct.pluck(:id)
                else
                  CourtOrder.where('created_at > ?', 1.week.ago).pluck(:id)
                end

    @files = FileUpload.where(notice: order_ids)
  end

  def write_files
    @files.each do |f|
      if f.kind == 'supporting'
        copy_file_to_archive(f)
      else
        notify_about_unredacted_files(f)
      end
    end
  end

  def copy_file_to_archive(f)
    # The first and third params ensure the filename is useful; the second
    # ensures it is unique. Stripping spaces and punctuation prevents problems
    # with invalid filenames.
    evil = /[\s$'"#=\[\]!><|;{}()*?~&\\]/
    name = "#{f.notice_id}_#{f.id}_#{f.file_file_name}".gsub(evil, '')
    system("cp #{Shellwords.escape(f.file.path)} '#{File.join(@working_dir, name)}'")
  end

  def notify_about_unredacted_files(f)
    return if f.notice.file_uploads.where(kind: 'supporting').present?
    File.write(
      @info_filepath,
      Rails.application.routes.url_helpers.notice_url(
        f.notice,
        host: Rails.application.config.action_mailer.default_url_options[:host]
      ),
      mode: 'a'
    )
  end

  def make_archive
    @loggy.info '[rake] Making court order reports archive'
    @archive_filename = Date.today.iso8601
    system("tar -czvf #{File.join(@base_dir, @archive_filename)}.tar.gz -C #{@working_dir} .")
    system("rm -r #{@working_dir}")
  end

  def email_users
    unless (emails && defined? SMTP_SETTINGS)
      @loggy.warn '[rake] Missing email or SMTP_SETTINGS; not emailing court order report'
      exit
    end

    @loggy.info '[rake] Sending court order report email'

    emails.each do |email|
      email_single_user(email)
    end
  end

  def emails
    @emails ||= begin
      JSON.parse ENV['USER_CRON_EMAIL']   # list of emails
    rescue JSON::ParserError
      [ENV['USER_CRON_EMAIL']]            # single-email string, as 1-item list
    end
  end

  def email_single_user(email)
    Net::SMTP.start(SMTP_SETTINGS[:address]) do |smtp|
      smtp.send_message mailtext, Chill::Application.config.default_sender, email
    end
  end

  def mailtext
    @mailtext ||= <<~HEREDOC
        Subject: Latest email archive from Lumen

        The latest archive of Lumen court order files can be found at
        #{Chill::Application.config.site_host}/#{@magic_dir}/#{@archive_filename}.tar.gz.
    HEREDOC
  end
end
