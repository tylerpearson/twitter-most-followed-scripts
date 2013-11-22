require 'twitter'
require 'colored'
require 'pp'
require 'CSV'
require 'json'
require "net/http"
require "uri"

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "jW3u9tE1MRWkkdmzlXVLIw"
  config.consumer_secret     = "I3cl1yfp3QbW4KWw1zNuYBu85owDmSITB82yxPc8nE"
  config.access_token        = "18587625-RmkLJb0UH8TB2oT7NRm8tAeVYiGNoriVURcWgO54"
  config.access_token_secret = "ibkeM3gif7nNZfB6HwwLezqfGvVwHRI7UIv2ZCGNs"
end


def load_user_lib(filename)
  JSON.parse(IO.read(filename))
end


GROUP = "us-senate"

accounts_to_check = load_user_lib("lists/#{GROUP}.json")

results = []


MAX_ATTEMPTS = 3

# check each account
accounts_to_check.each_with_index do |account, account_index|
  num_attempts = 0

  puts "#{account_index + 1} of #{accounts_to_check.size}: #{account}".green

  begin
    num_attempts += 1
    accounts_friends = client.friend_ids(account)

    accounts_friends.each_with_index do |following, following_index|

      results[following] = {name: account, count: 0, key: account, pages: []}

      results[following][:count] += 1
      results[following][:pages] << {name: following, key: following, title: following, url: "#"}
    end

    File.open("connections/#{GROUP}.json","w") do |f|
      f.write(results.to_json)
    end

    sleep 65 if accounts_to_check.size > 1

  rescue Twitter::Error::TooManyRequests => error
    if num_attempts <= MAX_ATTEMPTS
      puts "Rate limit error, sleeping until #{(Time.now + error.rate_limit.reset_in).strftime("%I:%M%p")}...".red
      sleep error.rate_limit.reset_in
      retry
    end
  rescue Twitter::Error::TooManyRequests => error
    if num_attempts <= MAX_ATTEMPTS
      puts "Rate limit error, sleeping until #{(Time.now + error.rate_limit.reset_in).strftime("%I:%M%p")}...".red
      sleep error.rate_limit.reset_in
      retry
    end
  rescue Twitter::Error::Unauthorized
    next
  end
end


puts "BRACE YOURSELF".green
pp results

