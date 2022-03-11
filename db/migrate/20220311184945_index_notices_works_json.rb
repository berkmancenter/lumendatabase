class IndexNoticesWorksJson < ActiveRecord::Migration[6.1]
  def up
    change_column_null :notices, :works_json, false
    execute(
"CREATE INDEX notices_works_json_urls_idx
ON notices USING gin (
  jsonb_path_query_array(works_json, '$.infringing_urls.url_original') jsonb_path_ops,
  jsonb_path_query_array(works_json, '$.copyrighted_urls.url_original') jsonb_path_ops
)
"
)
  end

  def down
    change_column_null :notices, :works_json, true
    execute("DROP INDEX notices_works_json_urls_idx")
  end
end
