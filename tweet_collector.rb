# encoding: utf-8

require 'json'
require 'twitter'
require_relative './lib/models'
require 'pp'
require_relative './lib/high_score_card'

class TweetCollector
  attr :score_card
  TWEETERS_HIGHSCORE = 'twitter_tweeters'

  attr :last_twitter_id, :last_call_time

  def initialize(score_card,last_twitter_id=0)
    @score_card      = score_card|| HighScoreCard.new
    @score_card.name = TWEETERS_HIGHSCORE
    @last_twitter_id = last_twitter_id || 0
  end

  def group_set_with_scores(set_with_scores)
    ret = []
    while k = set_with_scores.shift and v = set_with_scores.shift
      ret << [k, v.to_f]
    end
    ret
  end


  def trottle_twitter_call(dt)
    dt ? Time.now - dt < 60 : false
  end

  # Maps twitter tweet to local database
  def map_twitter_tweet(tweet)
    {created_at:        tweet.created_at,
     from_user:         tweet.from_user,
     text:              tweet.text,
     twitter_id:        tweet.id,
     profile_image_url: tweet.profile_image_url,
     source:            tweet.source,
     to_user:           tweet.to_user}
  end


  # Locates user information. First check locally then on twitter
  def get_user_info(twitter_id)
    user = User.first(twitter_id: twitter_id)
    if user
      user_data = user.twitter_attributes_json
    else
      user_data = Twitter.user(twitter_id).attrs
    end
    user_data
  end

  # Loads latest tweets from Twitter
  def update_tweets(tag, page=1)
    puts "tag=#{tag} page=#{page} last_twitter_id=#{@last_twitter_id}"
    Twitter.search(tag, rpp: 100, since_id: @last_twitter_id, page: page).each do |tweet|
      unless Tweet.count(:twitter_id => tweet.id.to_s) > 0
        user_info = get_user_info(tweet.from_user)
        Tweet.save_twitter_tweet(map_twitter_tweet(tweet), tweet.from_user, user_info["name"], tweet.profile_image_url, user_info)
        @last_twitter_id = tweet.id
        @score_card.score_add(tweet.from_user)
      end
    end
    @last_twitter_id
  end


  # Collects tweets for a given tag
  def get_tweet_data(num_tweeters=999, num_tweets=100)

    top_users = @score_card.score_card()

    users  = top_users.map do |u|
      p = User.first(twitter_id: u[0])
      puts "--- Fant ikke #{u[0]} u=#{u}" unless p
      if p
        u << p.profile_image_url
        u << p.name
      end
      u
    end

    #tweets = Tweet.all(order: :created_at.desc, limit: num_tweets)
    tweets = Tweet.all(order: :created_at.desc)

    [users, tweets]
  end

end
