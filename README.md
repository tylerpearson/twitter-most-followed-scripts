# Scripts to find the most commonly followed accounts by a group of accounts on Twitter

## Usage

First find a Twitter list for accounts you want to analyze. For example, the New Yorks Times maintains [a list of NYT journalists](https://twitter.com/nytimes/lists/nyt-journalists) on their official Twitter account. For this example, the username is `nytimes` and the list name is `nyt-journalists`.

Next, in the .env file, replace the sample variables from `.env.example` with the ones you want to use.

To get Twitter keys, visit https://apps.twitter.com/.

The results are saved to an S3 bucket, so that this container can be run anywhere (for example, as a task on ECS). You may need to log in to your AWS account and setup a user and IAM policy that has write access to the S3 bucket.

```bash
TWITTER_CONSUMER_KEY=xxx # Grab these from the Twitter developer console
TWITTER_CONSUMER_SECRET=xxx
TWITTER_ACCESS_TOKEN=xxx
TWITTER_ACCESS_TOKEN_SECRET=xxx
RESULTS_S3_BUCKET=xxx # Name of the S3 bucket where results should be uploaded
RESULTS_S3_BUCKET_PATH=results/ # Add the path in the bucket where the results should go
AWS_ACCESS_KEY_ID=xxx # AWS access keys that have permission to upload to the bucket
AWS_SECRET_ACCESS_KEY=xxx
```

Build the container with `docker build -t twitter-most-followed-scripts .` or use the container that is already built at https://hub.docker.com/r/tylerpearson/twitter-most-followed-scripts/.

Pass the username and list name as args to run the docker container:

```bash
docker run -d --env-file=.env \
           tylerpearson/twitter-most-followed-scripts:latest \
           username listname
```

## Blog Post

A write up of the results found during an analysis of U.S. and Canadian Olympians can be [viewed here](http://www.newmediacampaigns.com/blog/analyzing-who-olympians-follow-on-twitter).

## Results!

A Jekyll template that can be used to displayed the results is available in the [twitter-most-followed-site](https://github.com/tylerpearson/twitter-most-followed-site) repo.

Here are some results: shown through [Hifi](http://gethifi.com) templates.

* [2014 U.S. Winter Olympians](http://twitter.newmediacampaigns.com/2014-us-winter-olympians)
* [2012 U.S. Summer Olympians](http://twitter.newmediacampaigns.com/who-the-2012-us-summer-olympians-follow-on-twitter)
* [Canadian 2014 Winter Olympians](http://twitter.newmediacampaigns.com/who-the-canadian-2014-winter-olympians-follow-on-twitter)

![Screenshot](http://i.imgur.com/uZ3njN3.png)


## License

MIT.
