require './tweet_collector'
require 'redis'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/tweets.db")
DataMapper.auto_migrate!

desc "Henter alle tweets"
task :hent_alle_tweets do
  puts "henter alle tweets"
  redis = Redis.new
  (1..10).each do |page|
    puts "Collection page #{page}"

    TweetCollector.do_twitter_search(0, redis, '#roots2012',page)
    sleep(page * 10)
  end




end