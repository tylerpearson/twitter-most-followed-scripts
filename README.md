# Scripts to find the most commonly followed Twitter accounts by a group of people

## Usage

### Get a list of Twitter accounts to analyze

First find a Twitter list for accounts you want to analyze. For example, the New Yorks Times maintains [a list of NYT journalists](https://twitter.com/nytimes/lists/nyt-journalists) on their official Twitter account. After finding a list, update the list URL in `get-list.rb` to the new URL and change the `File.open` path to where you want the list saved. The default directory is `lists`.

Finally run `ruby get-list.rb`. A file with an array of Twitter ids for the members of the list be created in the `lists` directory (unless the directory is changed).

### Analyze who the list members follow

After changing the `GROUP` variable to the appropriate name, run the script with `ruby get-following.rb`. Once the script starts an estimate of when the script should finish will be printed. Depending on the number of people being analyzed, this could take a few hours.

There is a delay of 1 minute between each account to prevent hitting Twitter's API limits.

The default output directory for the results file is `dumps`. The results file countains all the Twitter ids for accounts list members follow with a count of how many list members follow it.

### Generate result files

The last script that needs to be run is `ruby get-results.rb`. Again, the `GROUP` variable should be updated. This script will generate:
1. A markdown file with results of the top 1000 accounts
2. A JSON file that contains additional data like username, description, profile image URL, and more for each account in the results. This can then be easily used in a [template to display the results in a prettier format](http://twitter.newmediacampaigns.com/2014-us-winter-olympians).

## Blog Post

A write up of the results found during an analysis of U.S. and Canadian Olympians can be [viewed here](http://www.newmediacampaigns.com/blog/analyzing-who-olympians-follow-on-twitter).

## Results!

Here are some results shown through [Hifi](http://gethifi.com) templates.

* [2014 U.S. Winter Olympians](http://twitter.newmediacampaigns.com/2014-us-winter-olympians)
* [2012 U.S. Summer Olympians](http://twitter.newmediacampaigns.com/who-the-2012-us-summer-olympians-follow-on-twitter)
* [Canadian 2014 Winter Olympians](http://twitter.newmediacampaigns.com/who-the-canadian-2014-winter-olympians-follow-on-twitter)

![Screenshot](http://i.imgur.com/uZ3njN3.png)