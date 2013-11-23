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

GROUP = "nyt-journalists"

# get the list that we are using
list = load_user_lib("lists/#{GROUP}.json") # load the information about the list

# grab the detail user info from Twitter
grabbed_info = client.users(list)

# Save all the list members info to a file in case we need it later
File.open("list_members_info/#{GROUP}.json","w") do |f|
  f.write(grabbed_info.map { |o| Hash[o] }.to_json)
end