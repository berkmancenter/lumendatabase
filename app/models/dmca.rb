class Dmca < Notice
  include SearchableNotice

  def self.model_name
    Notice.model_name
  end

  def to_partial_path
    'notices/notice'
  end
end
