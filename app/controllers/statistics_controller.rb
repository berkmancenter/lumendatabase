class StatisticsController < ApplicationController
  layout 'statistics'
  before_action :set_commons

  def notices
    @notices_count = Notice.get_approximate_count
    @average_count = @notices_count / ([1, Entity.count].max)
    @notice_topics = Notice::TYPES
  end

  def infringing_urls
    @urls_count = InfringingUrl.get_approximate_count
    @average_count = (@urls_count / ([1, Notice.get_approximate_count].max).to_f).ceil
  end

	def entities
		@unique_entities = Entity.count
	end

	def datewise_notices
		render json: Notice.group_by_year(:created_at).count
	end

	def datewise_urls
		@total_urls = InfringingUrl.get_approximate_count
		sample_count = [ENV.fetch('URLS_GRAPH_SAMPLE_SIZE', 100000), @total_urls].min
		sample_urls = url_sampling(sample_count)
		tt = sample_urls.group_by_year { |u| u }
		tt.each do |key, val|
			tt[key] = val.count * [1, @total_urls / sample_count].max
		end
		render json: tt
	end

	def pie_chart
		domain_count = Hash.new
		Notice::TYPES.each { |type| domain_count[type] = type.constantize.count }
		render json: domain_count.to_json 
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
	 	 "infringing urls",
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
	  	blog_entries_path,
	  	page_path("about"),
	  	page_path("research"),
	  	"/statistics/notices"
	  ]
	end

	def navbar_list
	  [
	  	"Blog",
	  	"About",
	  	"Research",
	  	"Dashboard"
	  ]
	end

	def url_sampling(sample_count)
		buckets = 10
		urls_arr = []
		for i in 0..buckets - 1 do 
			urls_arr.push(*InfringingUrl.limit(sample_count / buckets).offset(i * (@total_urls / buckets)).pluck(:created_at))
		end
		urls_arr
	end
end


