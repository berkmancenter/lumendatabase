class HomeController < ApplicationController
  layout 'home'

  def index
    @notices = Rails.cache.fetch("recent_notices", expires_in: 1.hour) { Notice.visible.recent }
    @blog_entries = BlogEntry.recent_posts
    client = Twitter::REST::Client.new do |config|
     config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
     config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
     config.access_token = ENV['TWITTER_OAUTH_TOKEN']
     config.access_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
    end
    
    if !fragment_exist?( 'chillingeffects-tweets' )
      begin
        @twitter_user = "lumendatabase"
        @tweet_news = client.user_timeline(@twitter_user, {count: 4})
      rescue Twitter::Error => e
        logger.error "Twitter fetch failed: #{e.message}"
        @tweet_news = []
      end
    end
  end
end
