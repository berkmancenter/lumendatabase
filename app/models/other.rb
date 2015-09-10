class Other < Notice

  define_elasticsearch_mapping

  def self.model_name
    Notice.model_name
  end

  def to_partial_path
    'notices/notice'
  end

  def sender_name
    "REDACTED"
  end

  def principal_name
    sender_name
  end

  def hide_identities?
    true
  end
end
