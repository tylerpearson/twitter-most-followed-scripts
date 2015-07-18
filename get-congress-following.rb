#!/usr/bin/env ruby

require 'twitter'
require 'colored'
require 'pp'
require 'CSV'
require 'json'
require 'net/http'
require 'uri'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ""
  config.consumer_secret     = ""
  config.access_token        = ""
  config.access_token_secret = ""
end

def load_user_lib(filename)
  JSON.parse(IO.read(filename))
end

accounts_to_check = load_user_lib("congress/lists/full-congress.json")

MAX_ATTEMPTS = 20

full_results = {}
gop_results = {}
dem_results = {}
house_results = {}
senate_results = {}

full_friends_hash = Hash.new(0)
gop_friends_hash = Hash.new(0)
dem_friends_hash = Hash.new(0)
house_friends_hash = Hash.new(0)
senate_friends_hash = Hash.new(0)


# give some info on when this thing should finish
estimated_time_finished = (Time.now + accounts_to_check.size * 65).strftime("%I:%M%p")
puts "This should finish at #{estimated_time_finished}".blue

accounts_to_check.each do |account_username, account_content|
  num_attempts = 0

  puts "#{account_username}".blue

  begin
    num_attempts += 1

    accounts_friends = client.friend_ids(account_username)

    friends_array = []

    accounts_friends.take(5000).each_with_index do |friend, account_friends_index|
      friends_array.push(friend)

      if account_content['party'] == "R"
        gop_friends_hash[friend] += 1
      end

      if account_content['party'] == "D"
        dem_friends_hash[friend] += 1
      end

      if account_content['chamber'] == "house"
        house_friends_hash[friend] += 1
      end

      if account_content['chamber'] == "senate"
        senate_friends_hash[friend] += 1
      end

      full_friends_hash[friend] += 1
    end

    # gop
    if account_content['party'].downcase == "r"
      gop_results[account_username] = friends_array

      File.open("congress/gop-count.json","w") do |f|
        f.write(gop_friends_hash.to_json)
      end

      File.open("congress/gop-full-results.json","w") do |f|
        f.write(gop_results.to_json)
      end
    end

    # dems
    if account_content['party'].downcase == "d"
      dem_results[account_username] = friends_array

      File.open("congress/dems-count.json","w") do |f|
        f.write(dem_friends_hash.to_json)
      end

      File.open("congress/dems-full-results.json","w") do |f|
        f.write(dem_results.to_json)
      end
    end

    # house
    if account_content['chamber'] == "house"
      house_results[account_username] = friends_array

      File.open("congress/house-count.json","w") do |f|
        f.write(house_friends_hash.to_json)
      end

      File.open("congress/house-full-results.json","w") do |f|
        f.write(house_results.to_json)
      end
    end

    # senate
    if account_content['chamber'] == "senate"
      senate_results[account_username] = friends_array

      File.open("congress/senate-count.json","w") do |f|
        f.write(senate_friends_hash.to_json)
      end

      File.open("congress/senate-full-results.json","w") do |f|
        f.write(senate_results.to_json)
      end
    end


    # full

    full_results[account_username] = friends_array

    File.open("congress/congress-count.json","w") do |f|
      f.write(full_friends_hash.to_json)
    end

    File.open("congress/congress-full-results.json","w") do |f|
      f.write(full_results.to_json)
    end

    sleep 65

  rescue Twitter::Error::TooManyRequests => error
    if num_attempts <= MAX_ATTEMPTS
      puts "Rate limit error, sleeping for #{error.rate_limit.reset_in} seconds...".red
      sleep error.rate_limit.reset_in
      retry
    end
  rescue Twitter::Error::Unauthorized
    puts "Unauthorized"
    next
  rescue => error
    if num_attempts <= MAX_ATTEMPTS
      puts "retrying"
      retry
    end
  end

end
