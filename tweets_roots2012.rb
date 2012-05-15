# encoding: utf-8

require 'bundler/setup'
require 'sinatra'
require 'twitter'
require 'data_mapper'
require 'dm-sqlite-adapter'
require './tweet_collector'
require 'sinatra/redis'
require_relative './lib/high_score_card'

enable :sessions, :logging

helpers do
  def hashtag_link(hashtag)
    "<a href='http://twitter.com/#!/search/%23#{hashtag}' target='twitter'>#{hashtag}</a>"
  end

  def twitter_user_link(user,extra=nil)
    "<a href='http://twitter.com/#!/#{user}' target='twitter'>@#{user} #{extra if extra}</a>"
  end


  def twitter_time(time)
    time.strftime("%d.%m.%Y %H:%M") if time
  end
end

configure do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/tweets.db")
  DataMapper.auto_upgrade!
end


get '/' do

  last_twitter_id =  redis.hget('tweets_roots2012_config', 'last_twitter_id')
  collector = TweetCollector.new(HighScoreCard.new(),last_twitter_id )
  last_twitter_id= collector.update_tweets('#roots2012')
  redis.hset('tweets_roots2012_config', 'last_twitter_id',last_twitter_id)
  puts "Latest twitter id = #{last_twitter_id}"

  @tweeters,@tweets =  collector.get_tweet_data
  erb :index
end

