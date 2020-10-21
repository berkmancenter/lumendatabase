class HomeController < ApplicationController
  layout 'home'

  def index
    # We cache the IDs, not the notices, because caching the notices will mean
    # the home page breaks if anything happens to change the structure of a
    # notice. (For example: serialization changes across rails versions;
    # Elasticsearch mapping changes.) The IDs will remain stable and we can
    # rehydrate them from the database without too much performance difference.
    # This is still faster than applying the visible & recent scopes each time.
    notice_ids = Rails.cache.fetch(
      'recent_notices', expires_in: 1.hour
    ) do
      @notices = Notice.visible.recent
      @notices.pluck(:id)
    end

    @notices ||= Notice.where(id: notice_ids)

    @blog_entries = blog_entries
  end

  def blog_entries
    Comfy::Cms::Page.find_by_label('blog_entries')
                    .children
                    .last(5)
                    .reverse
  rescue NoMethodError # when blog_entries undefined, or no children
    nil
  end
end
