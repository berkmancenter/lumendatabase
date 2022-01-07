module ActsAsTaggableOn
  class CommaParser < ActsAsTaggableOn::DefaultParser
    def delimiter
      ','.freeze
    end

    def double_quote_pattern
      /(\A|,)\s*"(.*?)"\s*(?=,\s*|\z)/
    end

    def single_quote_pattern
      /(\A|,)\s*'(.*?)'\s*(?=,\s*|\z)/
    end
  end
end
