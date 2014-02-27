require 'twitter'
require 'colored'
require 'pp'
require 'CSV'
require 'json'


client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "XXXX"
  config.consumer_secret     = "XXXX"
  config.access_token        = "XXXX"
  config.access_token_secret = "XXXX"
end


list_members = client.list_members('https://twitter.com/usolympic/london2012')

list_members_array = []

list_members.each_with_index do |member, index|
  list_members_array << member.id
end

File.open("lists/us-olympics-summer.json","w") do |f|
  f.write(list_members_array.to_json)
end