
require 'datamapper'

class Tweet
  include DataMapper::Resources

  property :id, Serial
  property :created_at, DateTime
  property :from_user, String, length: 100
  property :text, String, length:150
  property :twitter_id, String, length: 20
  property :profile_image_url, String, length: 255
  property :source, String, length: 255
  property :to_user, String, length: 100

  def save_twitter_tweet(src_tweet)

    t = self.create(src_tweet)
    t.twitter_id = src_tweet["id"]
    t.save
    t
  end
end

def get_tweet_data

  r = Redis.new

  tweeters,tweets,tag = {},[],'#roots2012'
  last_twitter_id = r.get('last_tweet')


  Twitter.search(tag, rpp: 100, since_id: last_twitter_id ).each do |tweet|

    Tweet.save_twitter_tweet(tweet)
    last_twitter_id = tweet.id

    tweets << tweet
    if tweeters.has_key?(tweet.from_user)
      tweeters[tweet.from_user][:cnt] = session[:users][tweet.from_user][:cnt]  + 1
    else
      tweeters[tweet.from_user] = {}
      tweeters[tweet.from_user][:pic] = tweet.profile_image_url
      tweeters[tweet.from_user][:cnt] = 1
    end

    [tweeters,tweets]
  end


end