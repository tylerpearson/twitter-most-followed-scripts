require 'twitter'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end


list_members = client.list_members('nytimes', 'nyt-journalists')

list_members_array = []

list_members.each do |member|
  list_members_array << member.id
end

File.open("lists/nytimes.json","w") do |f|
  if f.write(list_member_ids.to_json)
    puts "Downloaded list"
  end
end
