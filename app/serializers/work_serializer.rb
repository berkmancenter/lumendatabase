class WorkSerializer < ActiveModel::Serializer
  attributes :description
  has_many :infringing_urls, :copyrighted_urls

  FALLBACK = [{ url: 'No URL submitted' }].freeze

  def as_json(options = {})
    hash = super(options || {})
    if hash[:work][:infringing_urls].empty?
      hash[:work][:infringing_urls] = FALLBACK
    end
    if hash[:work][:copyrighted_urls].empty?
      hash[:work][:copyrighted_urls] = FALLBACK
    end
    hash
  end
end
