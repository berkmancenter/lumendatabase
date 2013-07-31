class Trademark < Notice
  include SearchableNotice

  def to_partial_path
    'notices/notice'
  end
end
