require "test/unit"
require 'data_mapper'
require 'dm-sqlite-adapter'
require 'benchmark'
require './tweet_collector'

class TweetCollectorTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/tweets.db")
    DataMapper.auto_upgrade!
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Fake test
  def test_collector
    
    Benchmark.bm do|b|
      b.report("update:tweets") do
        update_tweets('#roots2012')
      end
      b.report("update:tweets") do
        @tweeters, @tweets = get_tweet_data
      end
    end
  end
end