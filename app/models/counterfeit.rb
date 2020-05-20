# frozen_string_literal: true

class Counterfeit < Notice
  define_elasticsearch_mapping

  def self.label
    'Counterfeit'
  end

  def to_partial_path
    'notices/notice'
  end
end
