# encoding: utf-8

require 'data_mapper'
require 'json'
require 'redis'
require 'twitter'
require 'pp'


def check_dm_save(obj, data_src, message)
  unless obj.saved? then
    puts message
    obj.errors.each { |e| puts e } if obj.errors
    pp data_src
    pp obj
    raise message
  end
end


class User
  include DataMapper::Resource

  property :id, Serial
  property :name, String, length: 100
  property :profile_image_url, String, length: 255

  has n, :tweets

end


class Tweet
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime
  property :from_user, String, length: 100
  property :text, String, length:250
  property :twitter_id, String, length: 20
  property :profile_image_url, String, length: 255
  property :source, String, length: 255
  property :to_user, String, length: 100

  belongs_to :user

  def self.save_twitter_tweet(src_tweet)
    u = User.first_or_create(name: src_tweet[:from_user])
    if u.profile_image_url.to_s.length == 0
      u.profile_image_url = src_tweet[:profile_image_url]
      u.save
      check_dm_save u,src_tweet,'Hulk'
    end
    t = self.create(src_tweet)
    t.user = u
    t.save
    check_dm_save t,src_tweet,'Hulk 2'
    t
  end
end

def group_set_with_scores(set_with_scores)
  ret = []
  while k = set_with_scores.shift and v = set_with_scores.shift
    ret << [k, v.to_f]
  end
  ret
end


def trottle_twitter_call(dt)
  pp Time.now - dt
  dt ? Time.now - dt < 60 : false
end


def update_tweets(tag)
  r = Redis.new

  last_twitter_id = r.get("last_tweet_#{tag}")
  last_update = r.get("last_update")
  if last_update
    return if trottle_twitter_call(Time.parse(last_update))
  end

  Twitter.search(tag, rpp: 100, since_id: last_twitter_id ).each do |tweet|
    tweet_key = "tweet:#{tweet.id}"
    if !r.exists(tweet_key)
      t = Tweet.save_twitter_tweet({created_at: tweet.created_at, from_user: tweet.from_user, text: tweet.text, twitter_id: tweet.id, profile_image_url: tweet.profile_image_url, source: tweet.source, to_user: tweet.to_user})
      last_twitter_id = tweet.id
      r.zincrby('tweeters',1,tweet.from_user)
      r.set(tweet_key,tweet.to_json)
      last_twitter_id = tweet.id
    end
  end

  r.set("last_tweet_#{tag}",last_twitter_id)
  r.set("last_update",Time.now)
end

def get_tweet_data(num_tweeters=100,num_tweets=100)
  r = Redis.new
  top_users =  group_set_with_scores( r.zrevrange('tweeters',0,num_tweeters,with_scores: true))
  users = []
  top_users.each do |u|
    p = User.first(name: u[0])
    u << p.profile_image_url if p
    users << u
  end

  #tweets = Tweet.all(order: :created_at.desc, limit: num_tweets)
  tweets = Tweet.all(order: :created_at.desc)

  [users,tweets]
end