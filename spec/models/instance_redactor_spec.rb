require 'spec_helper'

describe InstanceRedactor::ContentRedactor do
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

describe InstanceRedactor::PhoneNumberRedactor do
  PHONE_NUMBERS = %w(
    123-456-7890
    123.456.7890
    123\ 456\ 7890
    (123)\ 456-7890
    456-7890
    456.7890
    456\ 7890
    90\ 212\ 326\ 06\ 15
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

describe InstanceRedactor::SSNRedactor do
  SSNS = %w(
    123-45-6789
    123.45.6789
  )

  SSNS.each do |ssn|
    it "redacts content like `#{ssn}'" do
      original_text = "Something with #{ssn} twice, #{ssn}."
      redacted_text = "Something with [REDACTED] twice, [REDACTED]."
      redactor = described_class.new

      redacted = redactor.redact(original_text)

      expect(redacted).to eq redacted_text
    end
  end
end

describe InstanceRedactor::EmailRedactor do
  EMAILS = %w(
    test@example.com
    someone@cyber.law.harvard.edu
    dot.man@gmail.com
  )

  EMAILS.each do |email|
    it "redacts content like `#{email}'" do
      original_text = "Something with #{email} twice, #{email}."
      redacted_text = "Something with [REDACTED] twice, [REDACTED]."
      redactor = described_class.new

      redacted = redactor.redact(original_text)

      expect(redacted).to eq redacted_text
    end
  end
end

describe InstanceRedactor do
  context "#redact" do
    it "passes the field's text through all redactors" do
      notice = build(:dmca, body: 'sensitive-a and sensitive-b')
      redactor = InstanceRedactor.new([
        InstanceRedactor::ContentRedactor.new('sensitive-a'),
        InstanceRedactor::ContentRedactor.new('sensitive-b')
      ])

      redactor.redact(notice, :body)

      expect(notice.body).to eq '[REDACTED] and [REDACTED]'
    end

    it "preserves the original text" do
      notice = build(:dmca, body: 'Some sensitive text')
      redactor = InstanceRedactor.new([
        InstanceRedactor::ContentRedactor.new('sensitive')
      ])

      redactor.redact(notice, :body)

      expect(notice.body_original).to eq 'Some sensitive text'
    end

    it "handles cases where the field's already redacted" do
      notice = build(
        :dmca,
        body: "Some [REDACTED] text",
        body_original: "Some sensitive text"
      )
      redactor = InstanceRedactor.new([
        InstanceRedactor::ContentRedactor.new('sensitive')
      ])

      redactor.redact(notice, :body)

      expect(notice.body).to eq "Some [REDACTED] text"
      expect(notice.body_original).to eq "Some sensitive text"
    end

    it "ignores stopwords" do
      notice = build(
        :dmca,
        body: "Text with the stopwords")
      redactor = InstanceRedactor.new([InstanceRedactor::ContentRedactor.new('the')])

      redactor.redact(notice, :body)

      expect(notice.body).to eq "Text with the stopwords"
    end
  end

  context "#redact_all" do
    it "redacts all notices by id" do
      notice_one = create(:dmca, body: 'One sensitive thing')
      notice_two = create(:dmca, body: 'Two sensitive thing')
      unaffected = create(:dmca, body: 'Three sensitive thing')
      redactor = InstanceRedactor.new([
        InstanceRedactor::ContentRedactor.new('sensitive')
      ])

      redactor.redact_all([notice_one.id, notice_two.id], :body)

      expect(notice_one.reload.body).to eq 'One [REDACTED] thing'
      expect(notice_two.reload.body).to eq 'Two [REDACTED] thing'
      expect(unaffected.reload.body).to eq 'Three sensitive thing'
    end
  end

  def simple_redactor(from, to)
    redactor = InstanceRedactor::ContentRedactor.new(from)
    allow(redactor).to receive(:mask).and_return(to)

    redactor
  end
end
