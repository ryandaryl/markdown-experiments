FROM ruby:3.2.3-slim-bullseye
RUN apt update && apt install -y build-essential
RUN gem install jekyll bundler
RUN echo 'export PATH=$PATH:/usr/local/bundle/bin; export GEM_HOME=/usr/local/bundle' >> /etc/profile
WORKDIR /opt
RUN jekyll new temp && rm -rf temp
