#!/usr/bin/env ruby
# frozen_string_literal: true

WINNING_SCORE = 3000
DICE_COUNT    = 5

def roll_dice(num_dice = DICE_COUNT)
  Array.new(num_dice) { rand(1..6) }
end

def calculate_score(dice)
  counts = Hash.new(0)
  dice.each { |d| counts[d] += 1 }

  score = 0

  counts.each do |num, count|
    if count >= 3
      if num == 1
        score += 1000
      else
        score += num * 100
      end

      if count > 3
        extra_sets = count - 3
        if num == 1
          score += 1000 * extra_sets
        else
          score += (num * 100) * extra_sets
        end
      end
    end
  end

  leftover_ones = counts[1] < 3 ? counts[1] : counts[1] - 3
  leftover_fives = counts[5] < 3 ? counts[5] : counts[5] - 3

  if leftover_ones.positive?
    score += leftover_ones * 100
  end
  if leftover_fives.positive?
    score += leftover_fives * 50
  end

  score
end

class Player
  attr_accessor :name, :banked_score, :current_turn_score

  def initialize(name)
    @name               = name
    @banked_score       = 0
    @current_turn_score = 0
  end

  def bank!
    @banked_score += @current_turn_score
    @current_turn_score = 0
  end

  def die!
    @current_turn_score = 0
  end

  def total_points
    @banked_score + @current_turn_score
  end
end

def play_game
  puts "Welcome to GREED (2-Player Edition)!"
  puts "Using the 'no one truly dies' rule."
  puts "First to #{WINNING_SCORE} points wins!"
  puts "-------------------------------------"

  player1 = Player.new("Player 1")
  player2 = Player.new("Player 2")

  players = [player1, player2]
  current_player_index = 0

  loop do
    current_player = players[current_player_index]

    puts "\n#{current_player.name}'s turn."
    puts "Banked Score: #{current_player.banked_score}, Current Turn Score: #{current_player.current_turn_score}"
    puts "Total Points (so far): #{current_player.total_points}"
    puts "Enter (r) to roll or (b) to bank =>"
    choice = gets.chomp.downcase

    case choice
    when 'r'
      dice_result = roll_dice
      roll_score = calculate_score(dice_result)

      puts "#{current_player.name} rolled: #{dice_result.inspect}"
      puts "Points in this roll = #{roll_score}"

      if roll_score.zero?
        puts "Oh no! Farkle/Die => losing unbanked points."
        current_player.die!
        current_player_index = 1 - current_player_index
      else
        current_player.current_turn_score += roll_score
        if current_player.total_points >= WINNING_SCORE
          puts "#{current_player.name} has reached #{current_player.total_points} points!"
          puts "#{current_player.name} wins!"
          break
        end
      end

    when 'b'
      current_player.bank!
      puts "#{current_player.name} banks! Their safe total is now #{current_player.banked_score}."
      if current_player.banked_score >= WINNING_SCORE
        puts "#{current_player.name} has banked #{current_player.banked_score} points!"
        puts "#{current_player.name} wins!"
        break
      end
      current_player_index = 1 - current_player_index

    else
      puts "Invalid choice. Please type 'r' to roll or 'b' to bank."
    end
  end

  puts "\nGame over. Final scores:"
  players.each do |p|
    puts "#{p.name}: #{p.total_points}"
  end

  puts "Thanks for playing!"
end

if __FILE__ == $PROGRAM_NAME
  play_game
end