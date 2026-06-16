require 'rails_helper'

describe EnterpriseReportJob, type: :job do
  let(:enterprise_report) do
    create(
      :enterprise_report,
      starts_at: Time.zone.local(2026, 6, 1),
      ends_at: Time.zone.local(2026, 6, 15).end_of_day
    )
  end

  it 'generates, attaches, and emails the requested report' do
    generated_report = instance_double(
      Lumen::Enterprise::NoticeReport,
      as_json: { notices: [] }
    )
    mailer = instance_double(ActionMailer::MessageDelivery, deliver_later: true)

    allow(Lumen::Enterprise::NoticeReport).to receive(:new)
      .and_return(generated_report)
    allow(Enterprise::ReportsMailer).to receive(:on_demand_report_ready)
      .and_return(mailer)

    described_class.perform_now(enterprise_report.id)

    enterprise_report.reload

    expect(Lumen::Enterprise::NoticeReport).to have_received(:new).with(
      enterprise_report.enterprise_account,
      starts_at: enterprise_report.starts_at,
      ends_at: enterprise_report.ends_at
    )
    expect(enterprise_report).to be_ready
    expect(enterprise_report.file).to be_attached
    expect(JSON.parse(enterprise_report.file.download)).to eq(
      'notices' => []
    )
    expect(Enterprise::ReportsMailer)
      .to have_received(:on_demand_report_ready)
      .with(enterprise_report)
    expect(mailer).to have_received(:deliver_later)
  end

  it 'marks the report failed when generation raises' do
    allow(Lumen::Enterprise::NoticeReport).to receive(:new)
      .and_raise(StandardError, 'boom')

    expect do
      described_class.perform_now(enterprise_report.id)
    end.to raise_error(StandardError, 'boom')

    enterprise_report.reload

    expect(enterprise_report).to be_failed
    expect(enterprise_report.failed_at).to be_present
    expect(enterprise_report.failure_message).to include('StandardError: boom')
  end
end
