class SubmitterWidgetMailer < ApplicationMailer
  def send_submitted_notice_copy(notice)
    notice_filtered = notice_for_email(notice)
    @content = json_to_html(notice_filtered)

    subject = "New notice submission #{notice.id}"

    attachments["notice_#{notice.id}.json"] = notice_filtered.to_json

    if notice.file_uploads.any?
      i = 1
      notice.file_uploads.each do |file_upload|
        file_ext = file_upload.file_file_name.split('.').last
        attachments["attachment_#{i}.#{file_ext}"] = File.read(file_upload.file.path)
        i += 1
      end
    end

    mail(
      to: notice.submitter.users.first.widget_submissions_forward_email,
      subject: subject
    )
  end

  private

  def notice_for_email(notice)
    entities_fields = %w[name kind address_line_1 address_line_2 state country_code phone email url city zip]

    json = notice.as_json(
      only: %w[id title body created_at subject language jurisdictions tags type mark_registration_number],
      include: {
        submitters: {
          only: entities_fields
        },
        senders: {
          only: entities_fields
        },
        principals: {
          only: entities_fields
        },
        recipients: {
          only: entities_fields
        },
        attorneys: {
          only: entities_fields
        }
      }
    )

    json[:works] = notice.works.map do |work|
      {
        description: work.description,
        infringing_urls: work.infringing_urls.map(&:url),
        copyrighted_urls: work.copyrighted_urls.map(&:url)
      }
    end

    json
  end

  def json_to_html(hash)
    output = '<ul>'

    hash.each do |key, value|
      output += '<li>'

      if value.is_a?(Hash)
        output += "#{key} #{json_to_html(value)}"
      elsif value.is_a?(Array)
        output += "<ul>#{key}:"

        value.each do |value_ar|
          if value_ar.is_a?(String) then
            output += "<li>#{value_ar}</li>"
          else
            output += "<li>#{json_to_html(value_ar)}</li>"
          end
        end

        output += '</ul>'
      else
        output += "#{key}: #{value}"
      end

      output += '</li>'
    end

    output += '</ul>'

    output
  end
end
