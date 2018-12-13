# have_words is like have_content but it removes whitespace (which was ignored
# by Capybara 2, hence by our tests, but is preserved by Capybara 3). It only
# accepts a String, not a Regexp or Fixnum. Adapted from
# https://groups.google.com/d/msg/ruby-capybara/o-IKGJNSInA/MHp_1mKkBQAJ .
RSpec::Matchers.define :have_words do |string|
  match do |page|
    string = string.gsub(/\s+/, ' ').strip
    re = Regexp.new(
      Regexp.escape(string)
            .gsub('\ ', '(?:\s+)')
            .gsub("'", "(?:'|&#39;)"), # in case of html entities
      Regexp::MULTILINE
    )
    have_content(re).matches?(page)
  end

  failure_message do |actual|
    "expected to find #{string.inspect} in:\n#{actual.text}"
  end

  failure_message_when_negated do |actual|
    "expected not to find #{string.inspect} in:\n#{actual.text}"
  end
end
