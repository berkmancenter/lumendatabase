class Defamation < Notice
	MASK = "REDACTED"
	REDACTION_REGEX = /google/i

  define_elasticsearch_mapping(works: [:description])

  def self.model_name
    Notice.model_name
  end

  def to_partial_path
    'notices/notice'
  end

  def sender_name
    if hide_identities?
      MASK
    else
      super
    end
  end

  def principal_name
    if hide_identities?
      MASK
    else
      super
    end
  end

  def hide_identities?
    recipient_name =~ REDACTION_REGEX
  end

end
