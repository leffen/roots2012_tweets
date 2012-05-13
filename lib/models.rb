# encoding: utf-8

require 'data_mapper'
require 'twitter-text'
require 'open-uri'

def check_dm_save(obj, data_src, message)
  unless obj.saved? then
    puts message
    obj.errors.each { |e| puts e } if obj.errors
    pp data_src
    pp obj
    raise message
  end
end


class User
  include DataMapper::Resource

  property :id, Serial
  property :name, String, length: 100
  property :profile_image_url, String, length: 255
  property :twitter_id, String, length: 100
  property :twitter_attributes_json, Text


  has n, :tweets
end


class Tweet
  include DataMapper::Resource
  include Twitter::Autolink
  include Twitter::Extractor

  property :id, Serial
  property :created_at, DateTime
  property :from_user, String, length: 100
  property :text, String, length:250
  property :twitter_id, String, length: 20
  property :profile_image_url, String, length: 255
  property :source, String, length: 255
  property :to_user, String, length: 100
  property :twitter_attributes_json, Text

  belongs_to :user, :required => false

  def self.save_twitter_tweet(src_tweet,twitter_id,name=nil,profile_image_url=nil, user_data={})

    usr = save_twitter_user(name, twitter_id, profile_image_url, user_data)

    t = self.create(src_tweet)
    t.user = usr if usr
    t.save
    check_dm_save t,src_tweet,'Hulk 2'
    t
  end

  def self.save_twitter_user(name, twitter_id, profile_image_url, user_data)
    u = User.first_or_create(twitter_id: twitter_id)
    if u.profile_image_url.to_s.length == 0
      puts "Adding user #{twitter_id}"
      u.profile_image_url = profile_image_url
      u.name = name if name
      u.twitter_attributes_json = user_data.to_json if user_data
      u.save
      check_dm_save u, src_tweet, 'Hulk'
    end
    u
  end

  def to_html
    extract_urls(@text).each do |url|
      #f = open(url)
      #puts "------ "
      #puts "url = #{url}"
      #puts f.readlines.join
    end

    auto_link(@text)
  end
end