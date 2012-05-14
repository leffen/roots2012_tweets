# encoding: utf-8

require 'redis'


class HighScoreCard
  attr :storage,:name

  def initialize(storage=nil,name="HighScoreCard")
    @name = name
    @storage = storage || redis.new
  end

  def reset
    @storage.del(@name)
  end

  def score_add(name,score_to_add=1)
    @storage.zincrby( @name , score_to_add, name)
  end

  def score_card(num_scores=9999)
    group_set_with_scores(@storage.zrevrange(@name, 0, num_scores, with_scores: true))
  end

  private
  def group_set_with_scores(set_with_scores)
    ret = []
    while k = set_with_scores.shift and v = set_with_scores.shift
      ret << [k, v.to_f]
    end
    ret
  end
end

