class StatisticsController < ApplicationController
  layout 'statistics'
  before_action :set_commons
  def statistics_notices
    @notices_count = Notice.get_approximate_count
    @average_count = @notices_count / ([1, Entity.count].max)
    @notice_topics = Notice::TYPES
    @date_line_graph = {}
  end

  def infringing_urls
    @urls_count = InfringingUrl.get_approximate_count
    @average_count = @urls_count / ([1, Notice.get_approximate_count].max)
    @date_line_graph = {}
  end

  def datewise_notices
    render json: Notice.group_by_year(:created_at).count
  end

  def pie_chart
    domain_count = Hash.new
    Notice::TYPES.each { |type| domain_count[type] = type.constantize.count }
    render json: domain_count.to_json 
  end

  def datewise_urls
    render json: InfringingUrl.group_by_year(:created_at).count
  end

  private

  def set_commons
    @sidebar_items = sidebar_items
    @sidebar_links = sidebar_links
    @navbar_list = navbar_list
    @navbar_link = navbar_link
  end

  def sidebar_items
    [
     "notices",
     "infringing url's",
     "entities",
     "visitors by country",
     "word cloud"
    ]
  end

  def sidebar_links
    [
    	"notices",
    	"infringing-urls",
    	"entities",
    	"visitors-by-country",
    	"wordcloud"
    ]
  end

  def navbar_link
    [
    	"/statistics/notices",
    	"/statistics/notices",
    	"/statistics/notices",
    	"/statistics/notices",
    	"/statistics/notices"
    ]
  end

  def navbar_list
    [
    	"Topics",
    	"Blog",
    	"About",
    	"Research",
    	"Dashboard"
    ]
  end
end


