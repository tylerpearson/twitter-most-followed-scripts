require 'twitter'
require 'colored'
require 'pp'
require 'CSV'
require 'json'
require 'fileutils'

# some helpful methods
def load_user_lib(filename)
  JSON.parse(IO.read(filename))
end

def twitter_user_info(twitter_id, users_information)
  users_information.select {|k| k['id'] == twitter_id.to_i}.first
end

def print_user_info(username, follower_count)
  comment = "#{username} has #{follower_count} list followers!"

  puts comment.red if follower_count <= 5
  puts comment.yellow if follower_count > 5 && follower_count < 100
  puts comment.blue if follower_count >= 100
end


# what list are we working with
GROUP = "nyt-journalists"

members_list = load_user_lib("lists/#{GROUP}.json")
relationships_list = load_user_lib("relationships/#{GROUP}.json")
users_data = load_user_lib("list-members-info/#{GROUP}.json")

# store the followers information in an array
follower_data = []

# loop through each member of the list
members_list.each_with_index do |list_member, index|

    # get the list member's information
    list_member_info = twitter_user_info(list_member, users_data)

    # create an array to store information on who the list member is following
    peeps_following = []

    # loop through each of the relationships
    relationships_list.each do |relationship|
      if relationship[1] == list_member # if the second id is the list member's
        peep_info = twitter_user_info(relationship[0], users_data) # get the users info of who is following them
        peeps_following << peep_info['screen_name'] # add that user's screen name to the people following the list member array
      end
    end

    # print to terminal each members info
    print_user_info(list_member_info['screen_name'], peeps_following.size)

    # add the information for the list member to the full data
    follower_data << {
        :username => list_member_info['screen_name'],
        :followers => peeps_following
      }
end


#pp follower_data

# save it to a file
File.open("hive-dumps/#{GROUP}.json","w") do |f|
  f.write(follower_data.to_json)
end
