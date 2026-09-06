# frozen_string_literal: true

require 'rails_helper'
require 'tempfile'

RSpec.describe Lumen::Maintenance::HideNoticesFromFile do
  def input_file(contents)
    Tempfile.new('notice-ids').tap do |file|
      file.write(contents)
      file.close
    end
  end

  it 'hides numeric references by notice id and CGI references by submission id' do
    notice_by_id = create(:dmca, submission_id: 111)
    notice_by_submission_id = create(:dmca, submission_id: 222)
    id_collision = create(:dmca, submission_id: notice_by_id.id)
    submission_id_collision = create(:dmca, submission_id: 333)
    input = input_file(<<~INPUT)
      #{notice_by_id.id}
      notice.cgi?sID=#{notice_by_submission_id.submission_id}
      https://www.example.com/notice.cgi?sID=#{submission_id_collision.id}
    INPUT

    described_class.new(path: input.path, output: StringIO.new).call

    expect(notice_by_id.reload).to be_hidden
    expect(notice_by_submission_id.reload).to be_hidden
    expect(id_collision.reload).not_to be_hidden
    expect(submission_id_collision.reload).not_to be_hidden
  ensure
    input&.unlink
  end

  it 'skips malformed and out-of-range references' do
    notice = create(:dmca, submission_id: 123)
    input = input_file(<<~INPUT)
      id
      0
      2147483648
      notice.cgi?NoticeID=#{notice.id}
      notice.cgi?sID=not-a-number
    INPUT
    output = StringIO.new

    runner = described_class.new(path: input.path, output: output).call

    expect(runner.processed_count).to eq(5)
    expect(runner.invalid_count).to eq(5)
    expect(runner.hidden_count).to eq(0)
    expect(notice.reload).not_to be_hidden
    expect(output.string).to include('Done: processed 5, newly hidden 0, invalid 5')
  ensure
    input&.unlink
  end

  it 'only reports notices that it newly hides and touches them for reindexing' do
    notice = create(:dmca)
    already_hidden = create(:dmca, hidden: true)
    input = input_file("#{notice.id}\n#{notice.id}\n#{already_hidden.id}\n999999999\n")
    notice.update_column(:updated_at, 1.day.ago)
    original_updated_at = notice.updated_at

    runner = described_class.new(path: input.path, batch_size: 2, output: StringIO.new).call

    expect(runner.hidden_count).to eq(1)

    expect(notice.reload.updated_at).to be > original_updated_at
    expect(notice).to be_hidden
  ensure
    input&.unlink
  end

  it 'supports a dry run without changing notices' do
    notice = create(:dmca)
    input = input_file("#{notice.id}\n")

    runner = described_class.new(path: input.path, dry_run: true, output: StringIO.new).call

    expect(runner.hidden_count).to eq(1)
    expect(notice.reload).not_to be_hidden
  ensure
    input&.unlink
  end
end
