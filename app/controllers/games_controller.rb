require 'open-uri'
require 'json'
require 'nokogiri'

class GamesController < ApplicationController
  def new
    @letters = []
    7.times { @letters << ("A".."Z").to_a.sample }
  end

  def score
    @result = {}
    @guess = params[:guess].gsub(/[^a-z]/i, '').upcase
    @letters = params[:grid].upcase.chars

    api_check = api_call(@guess)
    solutions = find_longest_possible_words(@letters)
    @result[:solutions] = solutions
    @result[:max_points] =  points(solutions.first, solutions)

    if word_in_grid?(@letters, @guess)
      @score = 0
      @result[:message] = "Sorry, but #{@guess} can't be built out of #{@letters.join(", ")}."
    elsif api_check["found"]
      @score = points(@guess, solutions)
      @result[:message] = "Congratulations! You have scored #{@score} points!"
    else
      @score = 0
      @result[:message] = "Sorry, but #{@guess} does not seem to be a valid English word."
    end
    session[:score] ? session[:score] += @score : session[:score] = 0
    session[:number_of_games] ? session[:number_of_games] += 1 : session[:number_of_games] = 1
  end

  private

  def api_call(guess)
    url = "https://wagon-dictionary.herokuapp.com/#{guess}"
    serialized_api_check = open(url).read
    JSON.parse(serialized_api_check)
  end

  def points(guess, solutions)
    solutions = [guess] if solutions.first.empty?

    solution_length = solutions.first.length
    guess.length ** 2 + (solution_length - (solution_length - guess.length)) ** 2
  end

  def word_in_grid?(grid, guess)
    word = guess.clone
    grid.each { |letter| word.sub!(letter, "") }
    word.chars.any?
  end

  def find_longest_possible_words(grid)
    url = "https://www.wordunscrambler.net/?word=#{grid.join}"

    html_content = open(url).read
    doc = Nokogiri::HTML(html_content)

    results = []
    doc.search('.clearfix .line.words a').each do |element|
      results << element.text.strip.upcase
    end
    find_longest_items_in_sorted_array(results)
    # select_existing_solutions(results)
  end

  def select_existing_solutions(solutions)
    results = solutions.select { |solution| api_call(solution)["found"] }
    results.first ? results : [""]
  end

  def find_longest_items_in_sorted_array(array)
    array.find_all { |string| string.length == array.first.length }
  end
end
