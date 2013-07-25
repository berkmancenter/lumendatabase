require 'spec_helper'

describe RedactsNotices::RedactsContent do
  it "redacts a literal string" do
    redactor = described_class.new('sens[itive]')

    redacted = redactor.redact("Some Sens[itive] thing with text: sens[itive]")

    expect(redacted).to eq "Some Sens[itive] thing with text: [REDACTED]"
  end

  it "redacts a regex" do
    redactor = described_class.new(/[Ss]ensitive/)

    redacted = redactor.redact("Some sensitive thing with text: Sensitive.")

    expect(redacted).to eq "Some [REDACTED] thing with text: [REDACTED]."
  end
end

describe RedactsNotices::RedactsPhoneNumbers do
  PHONE_NUMBERS = %w(
    123-456-7890
    123.456.7890
    123\ 456\ 7890
    (123)\ 456-7890
    456-7890
    456.7890
    456\ 7890
  )

  PHONE_NUMBERS.each do |phone_number|
    it "redacts content like `#{phone_number}'" do
      original_text = "Something with #{phone_number} twice, #{phone_number}."
      redacted_text = "Something with [REDACTED] twice, [REDACTED]."
      redactor = described_class.new

      redacted = redactor.redact(original_text)

      expect(redacted).to eq redacted_text
    end
  end
end

describe RedactsNotices do
  context "#redact" do
    it "passes the field's text through all redactors" do
      notice = build(:notice, legal_other: 'sensitive-a and sensitive-b')
      redactor = RedactsNotices.new([
        RedactsNotices::RedactsContent.new('sensitive-a'),
        RedactsNotices::RedactsContent.new('sensitive-b')
      ])

      redactor.redact(notice, :legal_other)

      expect(notice.legal_other).to eq '[REDACTED] and [REDACTED]'
    end

    it "preserves the original text" do
      notice = build(:notice, legal_other: 'Some sensitive text')
      redactor = RedactsNotices.new([
        RedactsNotices::RedactsContent.new('sensitive')
      ])

      redactor.redact(notice, :legal_other)

      expect(notice.legal_other_original).to eq 'Some sensitive text'
    end

  end

  context "#redact_all" do
    it "redacts all notices by id" do
      notice_one = create(:notice, legal_other: 'One sensitive thing')
      notice_two = create(:notice, legal_other: 'Two sensitive thing')
      unaffected = create(:notice, legal_other: 'Three sensitive thing')
      redactor = RedactsNotices.new([
        RedactsNotices::RedactsContent.new('sensitive')
      ])

      redactor.redact_all([notice_one.id, notice_two.id], :legal_other)

      expect(notice_one.reload.legal_other).to eq 'One [REDACTED] thing'
      expect(notice_two.reload.legal_other).to eq 'Two [REDACTED] thing'
      expect(unaffected.reload.legal_other).to eq 'Three sensitive thing'
    end
  end

  def simple_redactor(from, to)
    redactor = RedactsNotices::RedactsContent.new(from)
    redactor.stub(:mask).and_return(to)

    redactor
  end
end
