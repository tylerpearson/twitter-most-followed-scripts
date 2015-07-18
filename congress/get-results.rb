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
  config.consumer_key        = ""
  config.consumer_secret     = ""
  config.access_token        = ""
  config.access_token_secret = ""
end


GROUP = "senate"


# Load information needed for calculation
following = load_user_lib("dumps/#{GROUP}.json") # load the raw data
list = load_user_lib("lists/#{GROUP}.json") # load the information about the list


# Calculate the most followed people from the raw data
all_friends  = following.sort_by { |username, follow_count| follow_count }.reverse[0,1000]


# Get information from Twitter about the followees
friends_array = []

all_friends.each_with_index do |friend, index|
   friends_array << friend.first.to_i
end

friends_info = client.users(friends_array)


# Save all the followees info to a file (in case we need it later)
File.open("users_info/#{GROUP}.json","w") do |f|
  f.write(friends_info.map { |o| o.to_h }.to_json)
end


# Set up pretty results

md_doc = ""
json_hash = Hash.new()

all_friends.each_with_index do |friend, index|
  friend_info = friends_info.select {|k| k.id == friend.first.to_i}.first
  next if friend_info == nil

  # Markdown info
  md_result = "#{index + 1}. [@#{friend_info.screen_name}](http://twitter.com/#{friend_info.screen_name}) -- (#{friend.last} of #{list.size})\n"
  puts md_result
  md_doc << md_result

  # JSON info
  if json_hash[friend.last.to_i] == nil
    json_hash[friend.last.to_i] = []
  end

  json_hash[friend.last.to_i] << {
    id: index,
    twitter_id: friend_info.id,
    username: friend_info.screen_name.to_s,
    name: friend_info.name.to_s,
    location: friend_info.location.to_s,
    description: friend_info.description.to_s,
    url: friend_info.url.to_s,
    verified: friend_info.verified?,
    created_at: friend_info.created_at.to_s,
    image_url: friend_info.profile_image_url.to_s
  }
end


File.open("results/#{GROUP}.md","w") do |f|
  f.write(md_doc)
end

json_results = {"following" => []}
json_hash.map { |k, v| json_results["following"] << {:following_count => k, :accounts => v} }

File.open("results/#{GROUP}-data.json","w") do |f|
  f.write(json_results.to_json)
end
