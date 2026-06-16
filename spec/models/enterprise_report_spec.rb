require 'rails_helper'

describe EnterpriseReport, type: :model do
  it 'generates a unique download token' do
    first_report = create(:enterprise_report)
    second_report = create(:enterprise_report)

    expect(first_report.download_token).to be_present
    expect(second_report.download_token).to be_present
    expect(first_report.download_token).not_to eq(second_report.download_token)
  end

  it 'requires the report period to end after it starts' do
    report = build(
      :enterprise_report,
      starts_at: Time.zone.local(2026, 6, 10),
      ends_at: Time.zone.local(2026, 6, 10)
    )

    expect(report).not_to be_valid
    expect(report.errors[:ends_at]).to include('must be after start date')
  end

  it 'attaches generated JSON and marks the report ready' do
    report = create(
      :enterprise_report,
      starts_at: Time.zone.local(2026, 6, 1),
      ends_at: Time.zone.local(2026, 6, 15)
    )

    report.attach_json!('{"notices":[]}')

    expect(report).to be_ready
    expect(report).to be_downloadable
    expect(report.file).to be_attached
    expect(report.file.download).to eq('{"notices":[]}')
    expect(report.file.filename.to_s).to eq(
      'lumen-enterprise-report-2026-06-01-2026-06-15.json'
    )
  end
end
