FROM ruby:2.6.6

LABEL maintainer="mrio@umich.edu"

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  apt-transport-https

WORKDIR /usr/src/app

COPY ./ /usr/src/app/

RUN gem install bundler:2.1.4
ENV BUNDLE_PATH /gems

RUN bundle install

CMD tail -f /dev/null
