#!/usr/bin/env ruby

require 'twitter'
require 'colored'
require 'pp'
require 'CSV'
require 'json'
require "net/http"
require "uri"

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

def load_user_lib(filename)
  JSON.parse(IO.read(filename))
end


GROUP = "nytimes"

accounts_to_check = load_user_lib("lists/#{GROUP}.json")

MAX_ATTEMPTS = 20

# start the hash to save the info
friends_hash = Hash.new(0)
friends_array = []

# give some info on when this thing should finish
estimated_time_finished = (Time.now + accounts_to_check.size * 65).strftime("%I:%M%p")
puts "This should finish at #{estimated_time_finished}".blue

puts accounts_to_check.size

# check each account
accounts_to_check.each_with_index do |account_username, account_index|
  num_attempts = 0

  puts "#{account_index + 1} of #{accounts_to_check.size}: #{account_username}".green

  begin
    num_attempts += 1

    accounts_friends = client.friend_ids(account_username)

    accounts_friends.take(5000).each_with_index do |friend, account_friends_index|
      friends_array.push(friend)
      friends_hash[friend] += 1
    end

    File.open("dumps/#{GROUP}.json","w") do |f|
      f.write(friends_hash.to_json)
    end

    sleep 65 if accounts_to_check.size > 1

  rescue Twitter::Error::TooManyRequests => error
    if num_attempts <= MAX_ATTEMPTS
      puts "Rate limit error, sleeping for #{error.rate_limit.reset_in} seconds...".red
      sleep error.rate_limit.reset_in
      retry
    end
  rescue Twitter::Error::Unauthorized
    next
  rescue => error
    if num_attempts <= MAX_ATTEMPTS
      retry
    end
  end

end

