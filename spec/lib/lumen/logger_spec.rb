require 'rails_helper'

RSpec.describe Lumen::Logger do
  describe '.customize_rails_log_event' do
    let(:stack_trace) { ['app/jobs/example_job.rb:12', 'app/jobs/example_job.rb:4'] }
    let(:cleaned_stack_trace) { ['app/jobs/example_job.rb:12'] }

    before do
      allow(Rails.backtrace_cleaner).to receive(:clean)
        .with(stack_trace)
        .and_return(cleaned_stack_trace)
    end

    %w[ERROR FATAL].each do |severity|
      it "adds a stack trace to #{severity.downcase} events" do
        event = { 'severity' => severity }

        described_class.customize_rails_log_event(event, stack_trace)

        expect(event['event_type']).to eq('rails_log')
        expect(event['stack_trace']).to eq('app/jobs/example_job.rb:12')
      end
    end

    it 'does not add a stack trace to non-error events' do
      event = { 'severity' => 'INFO' }

      described_class.customize_rails_log_event(event, stack_trace)

      expect(event['event_type']).to eq('rails_log')
      expect(event).not_to have_key('stack_trace')
    end
  end
end
