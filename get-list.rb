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


list_members = client.list_members('https://twitter.com/katierogers/washington-post')

list_members_array = []

list_members.each_with_index do |member, index|
  list_members_array << member.id
end

File.open("lists/wapo-2.json","w") do |f|
  f.write(list_members_array.to_json)
end