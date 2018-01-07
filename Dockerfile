FROM ruby:2.3
MAINTAINER Tyler Pearson <ty.pearson@gmail.com>

RUN mkdir /usr/src/twitter-scripts
WORKDIR /usr/src/twitter-scripts

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN bundle install

COPY get-full-results.rb get-full-results.rb

ENTRYPOINT ["ruby", "/usr/src/twitter-scripts/get-full-results.rb"]
CMD ["TylerPearson", "test"]
