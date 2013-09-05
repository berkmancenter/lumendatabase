module IngestorHelpers
  def with_csv_linked_to_source_data(original_source_data)
    Tempfile.open('original_source_file') do |original_source_file|
      original_source_file.write(original_source_data)

      Tempfile.open('csv') do |csv_file|
        csv_row = default_csv_data.merge(OriginalFilePath: original_source_file.path)
        headers = csv_row.keys.sort
        csv = CSV.generate do |csv|
          csv << headers
          csv << headers.map{ |header| csv_row[header] }
        end
        csv_file.write(csv)
        csv_file.rewind

        yield (csv_file)
      end
    end
  end

  def default_csv_data
    {
      NoticeID: 123123,
      Subject: 'Subject',
      Sender_Principal: 'Sender',
      Recipient_Entity: 'Recipient',
      OriginalFilePath: nil
    }
  end

  def google_default_original_source_data
    %Q|
field_form_version:1
field_location_or_region:US
field_submitter_first_name:Joe
|
  end

end
