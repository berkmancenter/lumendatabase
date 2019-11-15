require 'rails_helper'

describe 'rake lumen:redact_and_reindex_works', type: :task, search: true do
  it 'redacts the works' do
    w = sensitive_work
    expect(Work.where(description: '012-34-5678').present?).to be true
    task.execute

    w.reload
    expect(w.description).to eq '[REDACTED]'
  end

  it 'marks notices as updated' do
    w = sensitive_work
    n = create(:dmca)
    w.notices << n
    original_updated_at = n.updated_at
    task.execute

    n.reload
    expect(n.updated_at).to be > original_updated_at
  end

  def sensitive_work
    w = create(:work)
    # Use update_columns because it doesn't trigger the before_save callback -
    # we want to make sure this isn't auto-redacted.
    w.update_columns(
      description: '012-34-5678',      # triggers SSN validation
      updated_at: Date.new(2008, 1, 1) # before the rails task's limit
    )
    w
  end
end

# task.execute
