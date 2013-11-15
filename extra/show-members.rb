require 'twitter'
require 'colored'
require 'pp'
require 'CSV'
require 'json'
require 'fileutils'


# helper methods
def load_user_lib(filename)
  JSON.parse(IO.read(filename))
end


# Twitter
client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "jW3u9tE1MRWkkdmzlXVLIw"
  config.consumer_secret     = "I3cl1yfp3QbW4KWw1zNuYBu85owDmSITB82yxPc8nE"
  config.access_token        = "18587625-RmkLJb0UH8TB2oT7NRm8tAeVYiGNoriVURcWgO54"
  config.access_token_secret = "ibkeM3gif7nNZfB6HwwLezqfGvVwHRI7UIv2ZCGNs"
end



# Load information needed for calculation
following = load_user_lib("../lists/startup-angels.json") # load the raw data


# Calculate the most followed people from the raw data
all_friends  = following.sort_by { |username, follow_count| follow_count }.reverse[0,1000]


# Get information from Twitter about the followees
friends_array = []

all_friends.each_with_index do |friend, index|
   friends_array << friend
end

friends_info = client.users(friends_array)




all_friends.each_with_index do |friend, index|
  friend_info = friends_info.select {|k| k["id"] == friend.to_i}.first
  next if friend_info == nil

  # Markdown info
  md_result = "#{index + 1}. #{friend_info.name} [@#{friend_info.screen_name}](http://twitter.com/#{friend_info.screen_name})\n"
  puts md_result



end



