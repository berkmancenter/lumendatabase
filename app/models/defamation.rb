class Defamation < Notice
  include SearchableNotice

  def self.model_name
    Notice.model_name
  end

  def to_partial_path
    'notices/notice'
  end

  def has_copyrighted_urls?
    false
  end

  def has_works_kind?
    false
  end
end
