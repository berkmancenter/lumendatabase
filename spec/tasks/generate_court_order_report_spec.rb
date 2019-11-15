require 'rails_helper'

describe 'rake lumen:generate_court_order_report', type: :task do
  before :all do
    create(:court_order, :with_document)
    @cached_user_cron_email = ENV['USER_CRON_EMAIL']
  end

  before(:each) do
    stub_const('SMTP_SETTINGS', { address: 'test@example.com' })
  end

  after :all do
    ENV['USER_CRON_EMAIL'] = @cached_user_cron_email
    CourtOrder.destroy_all
  end

  it 'sends a single email' do
    ENV['USER_CRON_EMAIL'] = 'foo@example.com'
    stub_smtp
    expect(@fake_smtp).to receive(:send_message)
      .with(anything, anything, 'foo@example.com')
    task.execute
  end

  it 'sends emails to a list' do
    ENV['USER_CRON_EMAIL'] = '["foo@example.com", "bar@example.com"]'
    stub_smtp
    expect(@fake_smtp).to receive(:send_message)
      .with(anything, anything, 'foo@example.com')
    expect(@fake_smtp).to receive(:send_message)
      .with(anything, anything, 'bar@example.com')
    task.execute
  end

  # SMTP may or may not be configured on the machines this test will run on,
  # so let's stub it out.
  def stub_smtp
    @fake_smtp = double('Net::STMP.new')
    allow(@fake_smtp).to receive(:send_message)
    allow(Net::SMTP).to receive(:start).and_yield @fake_smtp
  end
end
