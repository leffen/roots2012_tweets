# encoding: utf-8

require 'json'
require 'redis'
require 'twitter'
require_relative './lib/models'
require 'pp'

class TweetCollector
  TWITTER_USERS= 'twitter_users'
  TWITTER_TWEETS = 'twitter_tweets'
  TWEETERS_HIGHSCORE = 'twitter_tweeters'

  def initialize(redis=nil)
    @redis     = redis||Redis.new
  end

  def group_set_with_scores(set_with_scores)
    ret = []
    while k = set_with_scores.shift and v = set_with_scores.shift
      ret << [k, v.to_f]
    end
    ret
  end


  def trottle_twitter_call(dt)
    dt ? Time.now - dt < 60 : false
  end

  def map_twitter_tweet(tweet)
    {created_at: tweet.created_at, from_user: tweet.from_user, text: tweet.text, twitter_id: tweet.id, profile_image_url: tweet.profile_image_url, source: tweet.source, to_user: tweet.to_user}
  end

  def get_user_info(twitter_id)
    if @redis.hexists(TWITTER_USERS,twitter_id)
      user_data = @redis.hget(TWITTER_USERS,twitter_id)
    else
      user_data = Twitter.user(twitter_id)
      puts "user_data=#{user_data.attrs}"
      @redis.hset(TWITTER_USERS,twitter_id,user_data.attrs.to_json)
    end
    user_data
  end


  def do_twitter_search(last_twitter_id,  tag,page=1)
    Twitter.search(tag, rpp: 100, since_id: last_twitter_id, page: page).each do |tweet|
      unless @redis.hexists(TWITTER_TWEETS,tweet.id.to_s)
        puts "Adding tweet #{tweet.attrs}"
        t = Tweet.save_twitter_tweet(map_twitter_tweet(tweet),get_user_info(tweet.from_user))
        last_twitter_id = tweet.id
        @redis.zincrby( TWEETERS_HIGHSCORE , 1, tweet.from_user)
        @redis.hset( TWITTER_TWEETS, tweet.id.to_s, tweet.attrs.to_json)
        last_twitter_id = tweet.id
      end
    end
    last_twitter_id
  end

  def update_tweets(tag, page=1)
    last_twitter_id = @redis.get("last_tweet_#{tag}")
    last_update     = @redis.get("last_update")
    if last_update
      return if trottle_twitter_call(Time.parse(last_update))
    end

    puts "updates messages"
    last_twitter_id = do_twitter_search(last_twitter_id, tag, page)

    @redis.set("last_tweet_#{tag}", last_twitter_id)
    @redis.set("last_update", Time.now)
  end

  # Collects tweets for a given tag
  def get_tweet_data(num_tweeters=100, num_tweets=100)


    top_users = group_set_with_scores(@redis.zrevrange(TWEETERS_HIGHSCORE, 0, num_tweeters, with_scores: true))
    users     = []

    top_users.each do |u|
      p = User.first(name: u[0])
      u << p.profile_image_url if p
      users << u
    end

    #tweets = Tweet.all(order: :created_at.desc, limit: num_tweets)
    tweets = Tweet.all(order: :created_at.desc)

    [users, tweets]
  end

end
