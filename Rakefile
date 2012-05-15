require './tweet_collector'
require 'redis'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/tweets.db")
DataMapper.auto_upgrade!

desc "Henter alle tweets"
task :hent_alle_tweets do
  puts "henter alle tweets"

  collector = TweetCollector.new(HighScoreCard.new(Redis.new))
  (1..20).each do |page|
    puts "Collection page #{page}"

    collector.update_tweets('#roots2012', page)
    sleep(rand(10..55))
  end
end


def map_twitter_tweet(tweet)
  {created_at: tweet["created_at"], from_user: tweet.has_key?("from_user") ? tweet["from_user"] : tweet["user"]["screen_name"], text: tweet["text"], twitter_id: tweet["id"], profile_image_url: tweet["profile_image_url"], source: tweet["source"], to_user: tweet["to_user"]}
end


desc "Rebuilds score card based on database"
task :rebuild_score_card do
  score_card = HighScoreCard.new(Redis.new)
  score_card.name = TweetCollector::TWEETERS_HIGHSCORE
  score_card.reset
  Tweet.all().each do |tweet|
    score_card.score_add(tweet.from_user)
  end

end


