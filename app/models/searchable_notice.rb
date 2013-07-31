module SearchableNotice
  def self.included(base)
    base.after_touch { tire.update_index }

    base.mapping do
      base.indexes :id, index: 'not_analyzed', include_in_all: false
      base.indexes :title
      base.indexes :date_received, type: 'date', include_in_all: false
      base.indexes :rescinded, type: 'boolean', include_in_all: false
      base.indexes :tag_list, as: 'tag_list'
      base.indexes :jurisdiction_list, as: 'jurisdiction_list'
      base.indexes :sender_name, as: 'sender_name'
      base.indexes :sender_name_facet,
        analyzer: 'keyword', as: 'sender_name',
        include_in_all: false
      base.indexes :tag_list_facet,
        analyzer: 'keyword', as: 'tag_list',
        include_in_all: false
      base.indexes :jurisdiction_list_facet,
        analyzer: 'keyword', as: 'jurisdiction_list',
        include_in_all: false
      base.indexes :recipient_name, as: 'recipient_name'
      base.indexes :recipient_name_facet,
        analyzer: 'keyword', as: 'recipient_name', include_in_all: false
      base.indexes :country_code_facet,
        analyzer: 'keyword', as: 'country_code', include_in_all: false
      base.indexes :language_facet,
        analyzer: 'keyword', as: 'language', include_in_all: false
      base.indexes :categories, type: 'object', as: 'categories'
      base.indexes :category_facet,
        analyzer: 'keyword', as: ->(notice) { notice.categories.map(&:name) },
        include_in_all: false
      base.indexes :works,
        type: 'object',
        as: -> (notice){
          notice.works.as_json({
            only: [:description],
            include: {
              infringing_urls: { only: [:url] },
              copyrighted_urls: { only: [:url]}
            }
          })
        }
    end
  end
end
