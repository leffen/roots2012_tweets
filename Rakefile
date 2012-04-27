require './tweet_collector'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/tweets.db")
DataMapper.auto_migrate!

desc "Henter alle tweets"
task :hent_alle_tweets do
  puts "henter alle tweets"
  (1..30).each do |page|
    update_tweets('#roots2012',page)
    sleep(300)
  end




end