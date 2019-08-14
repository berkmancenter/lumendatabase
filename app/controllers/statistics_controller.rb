class StatisticsController < ApplicationController
	layout false
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

	private

	def set_commons
		@sidebar_items = sidebar_items
		@sidebar_links = sidebar_links
		@navbar_list = navbar_list
		@navbar_link = navbar_link
 	end

	def sidebar_items
		[
		 "NOTICES",
		 "INFRINGING URL'S",
		 "ENTITIES",
		 "VISITORS BY COUNTRY",
		 "WORD CLOUD"
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

		]
	end

	def navbar_list
		[

		]
	end
end


