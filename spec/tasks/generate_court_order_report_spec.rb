require 'rails_helper'

describe 'rake lumen:generate_court_order_report', type: :task do
  before :all do
    create(:court_order, :with_document)
    @cached_user_cron_email = ENV['USER_CRON_EMAIL']
    @cached_smtp = if defined? SMTP_SETTINGS
                     SMTP_SETTINGS
                   else
                     nil
                   end
    SMTP_SETTINGS = { address: 'test@example.com' }
  end

  after :all do
    ENV['USER_CRON_EMAIL'] = @cached_user_cron_email
    SMTP_SETTINGS = @cached_smtp if @cached_smtp
  end

  it 'sends a single email' do
    ENV['USER_CRON_EMAIL'] = 'foo@example.com'
    stub_smtp
    task.execute
    expect(@fake_smtp).to have_received(:send_message)
      .with(anything, anything, 'foo@example.com')
      .once
  end

  it 'sends emails to a list' do
    ENV['USER_CRON_EMAIL'] = '["foo@example.com", "bar@example.com"]'
    stub_smtp
    task.execute
    expect(@fake_smtp).to have_received(:send_message)
      .with(anything, anything, 'foo@example.com')
      .once
    expect(@fake_smtp).to have_received(:send_message)
      .with(anything, anything, 'bar@example.com')
      .once
  end

  # SMTP may or may not be configured on the machines this test will run on,
  # so let's stub it out.
  def stub_smtp
    @fake_smtp = double('Net::STMP.new')
    allow(@fake_smtp).to receive(:send_message)
    Net::SMTP.stub(:start).and_yield @fake_smtp
  end
end
