require 'validates_automatically'

class Work < ActiveRecord::Base
  include ValidatesAutomatically

  has_and_belongs_to_many :notices
  has_and_belongs_to_many :infringing_urls

  accepts_nested_attributes_for :infringing_urls

  validates_format_of :url, with: /^([a-z]{3,5}:)?\/\/.+/i

  def validate_associated_records_for_infringing_urls
    self.infringing_urls.map! do |infringing_url|
      InfringingUrl.find_or_initialize_by_url(infringing_url.url)
    end
  end

  before_save do
    if self.kind.blank?
      determiner = DeterminesWorkKind.new(url, infringing_urls.map(&:url))
      self.kind = determiner.kind
    end
  end
end
