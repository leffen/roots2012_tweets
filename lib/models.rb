# encoding: utf-8

require 'data_mapper'

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

  property :id, Serial
  property :created_at, DateTime
  property :from_user, String, length: 100
  property :text, String, length:250
  property :twitter_id, String, length: 20
  property :profile_image_url, String, length: 255
  property :source, String, length: 255
  property :to_user, String, length: 100
  property :twitter_attributes_json, Text

  belongs_to :user

  def self.save_twitter_tweet(src_tweet,user_data)
    u = User.first_or_create(twitter_id: src_tweet[:from_user])
    if u.profile_image_url.to_s.length == 0
      puts "Adding user #{user_data}"
      u.profile_image_url = src_tweet[:profile_image_url]
      u.name = user_data["name"] if user_data
      u.twitter_attributes_json = user_data.to_json if user_data
      u.save
      check_dm_save u,src_tweet,'Hulk'
    end
    t = self.create(src_tweet)
    t.user = u
    t.save
    check_dm_save t,src_tweet,'Hulk 2'
    t
  end
end