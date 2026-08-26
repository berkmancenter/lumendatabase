require 'rails_helper'

RSpec.describe Lumen::Logger do
  after { Current.reset }

  describe '.customize_rails_log_event' do
    let(:stack_trace) { ['app/jobs/example_job.rb:12', 'app/jobs/example_job.rb:4'] }

    %w[ERROR FATAL].each do |severity|
      it "adds the full stack trace to #{severity.downcase} events" do
        event = { 'severity' => severity }

        described_class.customize_rails_log_event(event, stack_trace)

        expect(event['event_type']).to eq('rails_log')
        expect(event['stack_trace']).to eq(
          "app/jobs/example_job.rb:12\napp/jobs/example_job.rb:4"
        )
      end
    end

    it 'does not add a stack trace to warnings' do
      event = { 'severity' => 'WARN' }

      described_class.customize_rails_log_event(event, stack_trace)

      expect(event['event_type']).to eq('rails_log')
      expect(event).not_to have_key('stack_trace')
    end

    it 'uses and clears a captured exception backtrace' do
      Current.exception_backtrace = ['app/models/notice.rb:123', 'app/controllers/notices_controller.rb:45']
      event = { 'severity' => 'ERROR' }

      described_class.customize_rails_log_event(event)

      expect(event['stack_trace']).to eq(
        "app/models/notice.rb:123\napp/controllers/notices_controller.rb:45"
      )
      expect(Current.exception_backtrace).to be_nil
    end
  end

  describe '.capture_exception_backtrace' do
    it 'captures the original exception backtrace' do
      exception = ActiveRecord::ValueTooLong.new('Value is too long')
      exception.set_backtrace(['app/models/notice.rb:123', 'app/controllers/notices_controller.rb:45'])

      described_class.capture_exception_backtrace(nil, exception)

      expect(Current.exception_backtrace).to eq(exception.backtrace)
    end
  end
end
