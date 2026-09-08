require 'rails_helper'

describe 'rake lumen:cleanup_completed_notice_submissions', type: :task do
  it 'clears only completed payloads' do
    completed = create(:notice_submission_request, status: 'completed')
    pending = create(:notice_submission_request, status: 'failed')

    task.execute

    expect(completed.reload.payload).to eq({})
    expect(pending.reload.payload).not_to eq({})
  end
end
