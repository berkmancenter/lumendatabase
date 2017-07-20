require 'rails_helper'

describe OriginalNewsIdsController do
  it_behaves_like "a redirecting controller for",
    BlogEntry, :blog_entry, :find_by_original_news_id
end
