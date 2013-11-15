require 'twitter'
require 'colored'
require 'pp'
require 'CSV'
require 'json'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "jW3u9tE1MRWkkdmzlXVLIw"
  config.consumer_secret     = "I3cl1yfp3QbW4KWw1zNuYBu85owDmSITB82yxPc8nE"
  config.access_token        = "18587625-RmkLJb0UH8TB2oT7NRm8tAeVYiGNoriVURcWgO54"
  config.access_token_secret = "ibkeM3gif7nNZfB6HwwLezqfGvVwHRI7UIv2ZCGNs"
end

# NMC
# accounts_to_check = [
#   "tylerpearson",
#   "newmediaclay",
#   "joelsutherland",
#   "Pascale_Georges",
#   "synair",
#   "aabennet",
#   "PatrickClarke",
#   "pomer",
#   "codeguy",
#   "claire_atwell",
#   "krisjordan"
# ]

# miami heat
# accounts_to_check = [
#   "PG30_MIA",
#   "MickyArison",
#   "easyst0",
#   "ShaneBattier",
#   "RealSwat32",
#   "mchalmers15",
#   "DwyaneWade",
#   "m33m",
#   "KingJames",
#   "chrisbosh"
# ]

# accounts_to_check = []

# CSV.foreach("senate.csv",{:headers => true}) do |row|
#   accounts_to_check << row[4]
# end

def load_user_lib( filename )
  JSON.parse( IO.read(filename) )
end

#accounts_to_check = load_user_lib('lists/current-nba.json')

accounts_to_check = [17461978,16812787,16125042]

MAX_ATTEMPTS = 3

# start the hash to save the info
#friends_hash = Hash.new(0)
friends_hash = load_user_lib('dumps/current-nba.json')
friends_array = []

# check each account
accounts_to_check.each_with_index do |account_username, account_index|
  num_attempts = 0

  puts "#{account_index + 1} of #{accounts_to_check.size}".green

  begin
    num_attempts += 1

    puts "#{account_username}".green
    accounts_friends = client.friend_ids(account_username)

    accounts_friends.take(5000).each_with_index do |friend, account_friends_index|
      friends_array.push(friend)
      puts "#{account_username}-#{account_friends_index + 1}: #{friend}".blue

      if friends_hash[friend.to_s] == nil
        friends_hash[friend.to_s] = 1
      else
        friends_hash[friend.to_s] += 1
      end
    end

    File.open("dumps/current-nba-3.json","w") do |f|
      f.write(friends_hash.to_json)
    end

    sleep 80 if accounts_to_check.size > 1

  rescue Twitter::Error::TooManyRequests => error
    if num_attempts <= MAX_ATTEMPTS
      puts "Rate limit error, sleeping for #{error.rate_limit.reset_in} seconds...".red
      sleep error.rate_limit.reset_in
      retry
    else
      raise
    end
  end

end

# all_friends = friends_hash.sort_by { |username, follow_count| follow_count }.reverse.take(100)
# friends_info = client.users(friends_array)

# puts "**********".green

# all_friends.each_with_index do |friend, index|
#   friend_info = friends_info.select {|k| k["id"] == friend.first}.first
#   puts "#{index}. [#{friend_info.screen_name}](http://twitter.com/#{friend_info.screen_name}) (#{friend.last} of #{accounts_to_check.size})"
# end

