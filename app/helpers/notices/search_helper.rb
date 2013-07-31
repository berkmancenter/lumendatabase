module Notices::SearchHelper
  def facet_display_name(facet_name)
    facet_name.gsub(/_facet/, '').titleize
  end
end
