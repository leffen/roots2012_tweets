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


def map_twitter_tweet(tweet)
  {created_at: tweet["created_at"], from_user: tweet.has_key?("from_user") ?  tweet["from_user"] : tweet["user"]["screen_name"], text: tweet["text"], twitter_id: tweet["id"], profile_image_url: tweet["profile_image_url"], source: tweet["source"], to_user: tweet["to_user"]}
end

task :sync_redis_dm do
  redis = Redis.new
  collector = TweetCollector.new(redis)
  redis.del( TweetCollector::TWEETERS_HIGHSCORE)
  redis.hkeys(TweetCollector::TWITTER_TWEETS).each do |tweet_key|
    tweet = JSON.parse(redis.hget(TweetCollector::TWITTER_TWEETS, tweet_key))
    user_data = tweet.has_key?("from_user") ? collector.get_user_info(tweet["from_user"]) : tweet["user"]
    if user_data.has_key?('profile_image_url')
      puts "***** #{user_data["screen_name"]} - #{user_data["name"]}  #{user_data["profile_image_url"]}"
    else
      pp user_data
    end
    Tweet.save_twitter_tweet(map_twitter_tweet(tweet),user_data["screen_name"],user_data["name"],user_data["profile_image_url"],user_data) if tweet
    redis.zincrby( TweetCollector::TWEETERS_HIGHSCORE , 1, user_data["screen_name"])
  end
end


