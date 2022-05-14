require "json"
require "open-uri"

class GamesController < ApplicationController
  def new
    @letters = 10.times.map do 
      ('A'..'Z').to_a.sample
    end
  end

  def score
    url = "https://wagon-dictionary.herokuapp.com/#{params[:attempt]}"
    grid = params[:letters].split
    attempt = params[:attempt]
    
    valid_to_grid = validate_to_grid(grid, attempt)
    valid_english, attempt_length = validate_to_english(url)
    
    @game_message = game_score(attempt, attempt_length, grid, valid_to_grid, valid_english)
    session[:grand_score] = 0 unless session[:grand_score]
    @grand_score = session[:grand_score]
  end

  private

  def validate_to_grid(grid, attempt)
    attempt.upcase.chars.all? { |letter| attempt.upcase.count(letter) <= grid.count(letter) }
  end

  def validate_to_english(url)
    attempt_serialized = URI.open(url).read
    attempt = JSON.parse(attempt_serialized)

    return attempt["found"], attempt["length"]
  end

  def game_score(attempt, attempt_length, grid, valid_to_grid, valid_english)
    if valid_to_grid && valid_english
      session[:grand_score] += attempt_length
      "Congratulations! #{attempt.upcase} is a valid English word..."
    elsif valid_to_grid
      "Sorry but #{attempt.upcase} does not seem to be a valid English word..."
    else
      "Sorry but #{attempt.upcase} can't be built out of #{grid.join(", ")}"
    end
  end
end
