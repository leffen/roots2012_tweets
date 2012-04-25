# encoding: utf-8

require 'bundler/setup'
require 'sinatra'
require 'twitter'
require 'data_mapper'
require 'dm-sqlite-adapter'
require './tweet_collector'

enable :sessions, :logging

helpers do
  def hashtag_link(hashtag)
    "<a href='http://twitter.com/#!/search/%23#{hashtag}' target='twitter'>#{hashtag}</a>"
  end

  def twitter_user_link(user,extra=nil)
    "<a href='http://twitter.com/#!/#{user}' target='twitter'>@#{user} #{extra if extra}</a>"
  end
end

configure do
  require 'redis'
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/tweets.db")
DataMapper.auto_upgrade!

get '/' do
  update_tweets('#roots2012')
  @tweeters,@tweets =  get_tweet_data
  
  erb :index
end

