class HomeController < ApplicationController
  layout 'home'

  def index
    @notices = Rails.cache.fetch(
      'recent_notices', expires_in: 1.hour
    ) { Notice.visible.recent }
    @blog_entries = BlogEntry.recent_posts
    fetch_tweets
  end

  private

  def fetch_tweets
    @tweet_news = []
    return if fragment_exist?('lumendatabase-tweets')

    begin
      twitter_user = 'lumendatabase'
      tweets = new_client.user_timeline(twitter_user, count: 4)
      @tweet_news = tweets if tweets.respond_to? :each
    rescue Twitter::Error => e
      logger.error "Twitter fetch failed: #{e.message}"
    end
  end

  def new_client
    Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token = ENV['TWITTER_OAUTH_TOKEN']
      config.access_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
    end
  end
end
