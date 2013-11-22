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

results = { nodes: [], links: [] }

MAX_ATTEMPTS = 4

# give some info on when this thing should finish
estimated_time_finished = (Time.now + accounts_to_check.size * 65).strftime("%I:%M%p")
puts "This should finish at #{estimated_time_finished}".blue

# check each account
accounts_to_check.each_with_index do |account, account_index|
  num_attempts = 0

  puts "#{account_index + 1} of #{accounts_to_check.size}: #{account}".green

  begin
    num_attempts += 1
    accounts_friends = client.friend_ids(account)

    results[:nodes] << {id: account, member: true}

    accounts_friends.each_with_index do |following, following_index|
      results[:nodes] << {id: following, member: false}
      results[:links] << {source: account, target: following, weight:1 }
    end

    File.open("connections/#{GROUP}.json","w") do |f|
      f.write(results.to_json)
    end

    sleep 65 if accounts_to_check.size > 1

  rescue Twitter::Error::TooManyRequests => error
    if num_attempts <= MAX_ATTEMPTS
      puts "Rate limit error, sleeping for #{error.rate_limit.reset_in} seconds...".red
      sleep error.rate_limit.reset_in
      retry
    end
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

puts "BRACE YOURSELF".green
pp results