class CreateResearcherTruncatedUrlsRole < ActiveRecord::Migration[6.1]
  def change
    Role.create(name: 'researcher_truncated_urls')
  end
end
