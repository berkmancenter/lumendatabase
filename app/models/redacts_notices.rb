class RedactsNotices
  def initialize(redactors = [RedactsPhoneNumbers.new, RedactsSSNs.new, RedactsEmail.new])
    @redactors = redactors
  end

  def redact(notice, field_or_fields = Notice::REDACTABLE_FIELDS)
    Array(field_or_fields).each { |field| redact_field(notice, field) }
  end

  def redact_all(notice_ids, field_or_fields = Notice::REDACTABLE_FIELDS)
    Notice.where(id: notice_ids).each do |notice|
      redact(notice, field_or_fields)
      notice.save
    end
  end

  private

  attr_reader :redactors

  def redact_field(notice, field)
    if (text = notice.send(field)).present?
      new_text = redactors.inject(text) do |result, redactor|
        redactor.redact(result)
      end

      notice.send(:"#{field}=", new_text)

      if notice.send(:"#{field}_original").blank?
        notice.send(:"#{field}_original=", text)
      end
    end
  end

  class RedactsContent
    STOP_WORDS = %w(
      a about above across after again against all almost alone along already also although always among an and another any anybody anyone anything
      anywhere are area areas around as ask asked asking asks at away b back backed backing backs be became because become becomes been before began
      behind being beings best better between big both but by c came can cannot case cases certain certainly clear clearly come could d did differ 
      different differently do does done down down downed downing downs during e each early either end ended ending ends enough even evenly ever 
      every everybody everyone everything everywhere f face faces fact facts far felt few find finds first for four from full fully further furthered 
      furthering furthers g gave general generally get gets give given gives go going good goods got great greater greatest group grouped grouping 
      groups h had has have having he her here herself high high high higher highest him himself his how however i if important in interest interested
      nteresting interests into is it its itself j just k keep keeps kind knew know known knows l large largely last later latest least less let lets
      like likely long longer longest m made make making man many may me member members men might more most mostly mr mrs much must my myself n necessary
      need needed needing needs never new new newer newest next no nobody non noone not nothing now nowhere number numbers o of off often old older
      oldest on once one only open opened opening opens or order ordered ordering orders other others our out over p part parted parting parts per
      perhaps place places point pointed pointing points possible present presented presenting presents problem problems put puts q quite r rather
      really right right room rooms s said same saw say says second seconds see seem seemed seeming seems sees several shall she should show showed
      showing shows side sides since small smaller smallest so some somebody someone something somewhere state states still still such sure t take
      taken than that the their them then there therefore these they thing things think thinks this those though thought thoughts three through thus
      to today together too took toward turn turned turning turns two u under until up upon us use used uses v very w want wanted wanting wants was
      way ways we well wells went were what when where whether which while who whole whose why will with within without work worked working works
      would x y year years yet you young younger youngest your yours z
    )
    def initialize(string_or_regex)
      @string_or_regex = string_or_regex
    end

    def redact(content)
      content.gsub(@string_or_regex) { |s| STOP_WORDS.include?(s) ? s : mask }
    end

    def mask
      Lumen::REDACTION_MASK
    end
  end

  class RedactsPhoneNumbers
    def redact(text)
      redactor = RedactsContent.new(
        /(\(?\d{3}\)?.?)? # optional area code
         (\d{3}[^\d]?\d{4})| # phone number, optional single-char separator
         (\d+[\d ]{10,16}\d+) # turkish phone number
        /x
      )

      redactor.redact(text)
    end
  end

  class RedactsSSNs
    def redact(text)
      redactor = RedactsContent.new(
        /\b(\d{3})\D?(\d{2})\D?(\d{4})\b/x
      )

      redactor.redact(text)
    end
  end

  class RedactsEmail
    def redact(text)
      redactor = RedactsContent.new(
        /\S+@\S+\.\S+[^.\s]/i
      )

      redactor.redact(text)
    end
  end

  class RedactsEntityName
    def initialize(name)
      match = name.gsub(/[-*+?\d]/, ' ').strip.split(/\s+/)
      separator = (name =~ /[a-z]/mi ? '[^a-z]' : '\s')
      @regex_base = "(?:#{match.join('|')})(?:#{separator}*(?:#{match.join('|')}))*"
      @regex = /#{@regex_base}/mi
    end

    def redact(text)
      return text if @regex_base.blank?
      redactor = RedactsContent.new(@regex)

      redactor.redact(text)
    end
  end
end
