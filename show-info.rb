require 'twitter'
require 'colored'
require 'pp'
require 'CSV'
require 'json'
require 'fileutils'


def load_user_lib(filename)
  JSON.parse(IO.read(filename))
end

GROUP = "nyt-journalists"

start_list = load_user_lib("lists/#{GROUP}.json")
initial_list = load_user_lib("relationships/#{GROUP}.json")
users_data = load_user_lib("list-members-info/#{GROUP}.json")

follower_data = []

start_list.each_with_index do |list_member, index|

    list_member_info = users_data.select {|k| k["id"] == list_member.to_i}.first

    peeps_following = []

    initial_list.each_with_index do |relationship, j|
      if relationship[1] == list_member
        peep_id = relationship[0]
        peep_info = users_data.select {|k| k["id"] == peep_id.to_i}.first
        peeps_following << peep_info['screen_name']
      end
    end

    follower_data << {
        :username => list_member_info['screen_name'],
        :followers => peeps_following
      }
end


pp follower_data

File.open("hive-dumps/#{GROUP}.json","w") do |f|
  f.write(follower_data.to_json)
end