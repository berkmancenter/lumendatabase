class HomeController < ApplicationController
  layout 'home'

  def index
    @notices = Notice.visible.recent
    @blog_entries = BlogEntry.recent
    client = Twitter::REST::Client.new do |config|
     config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
     config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
     config.oauth_token = ENV['TWITTER_OAUTH_TOKEN']
     config.oauth_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
    end
    
    @twitter_user = "chillingeffects"
    @tweet_news = client.user_timeline(@twitter_user, {count: 4})
  end
end