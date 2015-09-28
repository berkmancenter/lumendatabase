class DMCA < Notice

  define_elasticsearch_mapping

  def self.model_name
    Notice.model_name
  end

  def self.label
    'DMCA'
  end

  def to_partial_path
    'notices/notice'
  end
end
