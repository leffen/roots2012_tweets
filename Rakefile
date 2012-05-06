require './tweet_collector'
require 'redis'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/tweets_a_lot.db")
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


task :list_old_tweets do
  redis = Redis.new
  Tweet.all().each do |tweet|
    begin
    unless redis.hexists(TweetCollector::TWITTER_TWEETS,tweet.twitter_id.to_s)
      puts "Prover aa hente #{tweet.twitter_id.to_s}"
      ts = Twitter.status(tweet.twitter_id.to_s)
      redis.hset( TweetCollector::TWITTER_TWEETS, tweet.twitter_id.to_s, ts.attrs.to_json) if ts
    end
    unless redis.hexists(TweetCollector::TWITTER_USERS,tweet.from_user)
      user_data = Twitter.user(tweet.from_user)
      if user_data
        puts "user_data=#{user_data}"
        redis.hset(TweetCollector::TWITTER_USERS,tweet.from_user,user_data.attrs.to_json)
      end
    end
    rescue => e
      puts e.inspect
    end

  end
end


