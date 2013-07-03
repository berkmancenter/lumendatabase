require 'spec_helper'

shared_examples "a redactor of" do |values|
  values.each do |value|
    it "redacts values that look like '#{value}'" do
      original_text = "Some text with #{value} in it twice: #{value}."
      redacted_text = "Some text with [REDACTED] in it twice: [REDACTED]."

      result = described_class.new(original_text).redacted

      expect(result).to eq redacted_text
    end
  end
end

describe RedactsNotices::RedactsRegex do
  it "raises if #regex is not defined" do
    expect { described_class.new('').regex }.to raise_error(NotImplementedError)
  end
end

describe RedactsNotices::RedactsPhoneNumbers do
  it_behaves_like "a redactor of",
    %w( 123-456-7890 123.456.7890 123\ 456\ 7890 (123)\ 456-7890
        456-7890 456.7890 456\ 7890 )
end

describe RedactsNotices do
  context "#redact" do
    it "passes the field's text through all redactors" do
      notice = create(:notice, legal_other: 'foo bar baz bat')
      redactor = RedactsNotices.new([
        simple_redactor('foo', 'bar'),
        simple_redactor('bar', 'baz')
      ])

      redactor.redact(notice, :legal_other)

      expect(notice.legal_other).to eq 'baz baz baz bat'
    end

    it "preserves the original text" do
      notice = create(:notice, legal_other: 'foo bar baz')
      redactor = RedactsNotices.new([
        simple_redactor('foo', 'bar')
      ])

      redactor.redact(notice, :legal_other)

      expect(notice.legal_other_original).to eq 'foo bar baz'
    end

    def simple_redactor(from, to)
      Class.new(RedactsNotices::RedactsRegex) do
        class_eval <<-EOC
          def regex; /#{from}/ end
          def mask; '#{to}' end
        EOC
      end
    end
  end
end
