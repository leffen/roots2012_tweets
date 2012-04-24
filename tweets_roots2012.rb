# encoding: utf-8

require 'sinatra'
require 'twitter'
require 'redis'
require 'datamapper'
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

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/tweets.db")
DataMapper.auto_migrate!

get '/' do
  @tweeters,@tweets =  get_tweet_data
  
  erb :index
end

