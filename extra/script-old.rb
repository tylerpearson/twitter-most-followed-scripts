require 'twitter'
require 'colored'
require 'pp'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "jW3u9tE1MRWkkdmzlXVLIw"
  config.consumer_secret     = "I3cl1yfp3QbW4KWw1zNuYBu85owDmSITB82yxPc8nE"
  config.access_token        = "18587625-RmkLJb0UH8TB2oT7NRm8tAeVYiGNoriVURcWgO54"
  config.access_token_secret = "ibkeM3gif7nNZfB6HwwLezqfGvVwHRI7UIv2ZCGNs"
end

MAX_ATTEMPTS = 3

# check these accounts
accounts_to_check = [
  "tylerpearson",
  "nmcteam",
  "newmediaclay",
  "joelsutherland"
]

# start the hash to save the info
friends_hash = Hash.new(0)

# check each account
accounts_to_check.each_with_index do |account_username, account_index|

  num_attempts = 0

  begin
    num_attempts += 1
    accounts_friends = client.friends(account_username).take(500)

    accounts_friends.each_with_index do |friend, account_friends_index|

      puts "#{account_username}-#{account_friends_index + 1}: #{friend.name} (#{friend.followers_count} followers)".blue

      friends_hash[friend.screen_name] += 1

      exit if account_friends_index > 50
      sleep 1
    end
  rescue Twitter::Error::TooManyRequests => error
    if num_attempts <= MAX_ATTEMPTS
      puts "Rate limit error, sleeping for #{error.rate_limit.reset_in} seconds...".red
      sleep error.rate_limit.reset_in
      retry
    else
      raise
    end
  end

  sleep 60
end

pp friends_hash.sort_by { |username, follow_count| follow_count }.reverse