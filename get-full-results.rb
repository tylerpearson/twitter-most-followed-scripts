require 'twitter'
require 'logger'
require 'aws-sdk-s3'

logger = Logger.new(STDOUT)
logger.level = Logger::INFO

$stdout.sync = true

ROOT_TWITTER_ACCOUNT = ARGV[0]
ROOT_LIST_NAME = ARGV[1]
GROUP = "#{ROOT_TWITTER_ACCOUNT}-#{ROOT_LIST_NAME}".freeze
MAX_ATTEMPTS = 20

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

logger.info("Username: #{ROOT_TWITTER_ACCOUNT}")
logger.info("List: #{ROOT_LIST_NAME}")
logger.info("Loading #{GROUP} list")

# Get the Twitter account ids of the members of the list
accounts_to_check_cursor = client.list_members(ROOT_TWITTER_ACCOUNT, ROOT_LIST_NAME)
accounts_to_check = []
accounts_to_check_cursor.each { |member| accounts_to_check << member.id }

friends_hash = Hash.new(0)
friends_array = []

logger.info("Searching through #{accounts_to_check.size} accounts")

# Get a list of ids that each account in the list follows
accounts_to_check.each_with_index do |account_username, account_index|
  num_attempts = 0

  logger.info("#{account_index + 1} of #{accounts_to_check.size}: #{account_username}")

  begin
    num_attempts += 1

    accounts_friends = client.friend_ids(account_username)

    accounts_friends.take(5000).each do |friend|
      friends_array << friend
      friends_hash[friend] += 1
    end

    sleep 60 if accounts_to_check.size > 1

  rescue Twitter::Error::TooManyRequests => error
    if num_attempts <= MAX_ATTEMPTS
      logger.warn("Rate limit error, sleeping for #{error.rate_limit.reset_in} seconds...")
      sleep error.rate_limit.reset_in
      retry
    end
  rescue Twitter::Error::Unauthorized
    next
  rescue => error
    if num_attempts <= MAX_ATTEMPTS
      retry
    end
  end

end


# Load information needed for calculation
# Temp copy pasta fix
following = friends_hash # load the raw data
list = accounts_to_check # load the information about the list

# Calculate the most followed people from the raw data
all_friends  = following.sort_by { |username, follow_count| follow_count }.reverse[0,1000]

# Get information from Twitter about the followees
friends_array = []

all_friends.each do |friend|
   friends_array << friend.first.to_i
end

friends_info = client.users(friends_array)

# Set up pretty results
following_results = {}

all_friends.each_with_index do |friend, index|
  friend_info = friends_info.select {|k| k.id == friend.first.to_i}.first
  next if friend_info == nil

  # JSON info
  if following_results[friend.last.to_i] == nil
    following_results[friend.last.to_i] = []
  end

  following_results[friend.last.to_i] << {
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

json_results = { "list_length" => accounts_to_check.size,
                 "finished_at_formatted" => DateTime.now.strftime("%b %d %Y"),
                 "following"   => [] }

following_results.map { |k, v| json_results["following"] << {following_count: k, accounts: v} }

s3 = Aws::S3::Resource.new(region: 'us-east-1')
file_name = "#{ENV['RESULTS_S3_BUCKET_PATH']}#{GROUP}-results.json"
obj = s3.bucket(ENV['RESULTS_S3_BUCKET']).object(file_name)
obj.put(body: json_results.to_json)

logger.info("Finished!")

