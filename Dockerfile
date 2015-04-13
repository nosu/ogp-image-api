FROM redis
MAINTAINER nosu

# Install ruby and bundler
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get -y install \
    build-essential \
    curl \
    git-core \
    libcurl4-openssl-dev \
    libreadline-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    libyaml-dev \
    zlib1g-dev && \
    curl -O http://ftp.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.gz && \
    tar -zxvf ruby-2.1.2.tar.gz && \
    cd ruby-2.1.2 && \
    ./configure --disable-install-doc && \
    make && \
    make install && \
    cd .. && \
    rm -r ruby-2.1.2 ruby-2.1.2.tar.gz && \
    echo 'gem: --no-document' > /usr/local/etc/gemrc

RUN \
  echo 'gem: --no-rdoc --no-ri' >> /.gemrc && \
  gem install bundler

# Copy app src
RUN mkdir /og-image-api
WORKDIR /og-image-api

ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
# RUN bundle config without test development doc
RUN bundle install
ADD . /og-image-api
