require './tweet_collector'
require 'redis'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/tweets.db")
DataMapper.auto_upgrade!

desc "Henter alle tweets"
task :hent_alle_tweets do
  puts "henter alle tweets"
  collector = TweetCollector.new
  (1..20).each do |page|
    puts "Collection page #{page}"

    collector.do_twitter_search(0, '#roots2012',page)
    sleep(rand(10..55))
  end




end