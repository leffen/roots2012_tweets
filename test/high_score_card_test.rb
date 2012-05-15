# encoding: utf-8

require "test/unit"
require 'pp'
require_relative '../lib/high_score_card'

class HighScoreCardTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @score_card = HighScoreCard.new(Redis.new,'Test_HScoreCard')
    @score_card.reset
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Fake test
  def test_score_card
    @score_card.score_add('test_x1')
    card = @score_card.score_card()
    assert_equal 1,card.count,'Her burde det bare være en på high score listen'
    assert_equal 'test_x1',card[0][0],'Test1 burde befunnet seg i første rad'

    (1..100).each{|num|@score_card.score_add("test_#{num}") }
    card = @score_card.score_card()
    assert_equal 101,card.count,'Her burde det bare være 100 på high score listen'
    (1..100).each{|num|@score_card.score_add("test_1") }
    card = @score_card.score_card()
    assert_equal 101,card[0][1], 'Score burde ha vært korrekt'
    assert_equal 1,card[1][1], 'Score burde ha vært korrekt'




  end
end