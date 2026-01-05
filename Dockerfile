# 1. Use Ruby 3.3 with Debian Bullseye
FROM ruby:3.3-bullseye

# 2. Install dependencies: Postgres client, PostGIS, Node.js, Yarn
RUN apt-get update -qq && apt-get install -y \
    postgresql-client \
    libpq-dev \
    libgeos-dev \
    libproj-dev \
    curl \
    gnupg \
    build-essential \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update -qq && apt-get install -y yarn \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Set working directory
WORKDIR /app

# 4. Copy Gemfile and Gemfile.lock first for caching
COPY Gemfile* ./

# 5. Install correct Bundler version (matching your Gemfile.lock)
RUN gem install bundler -v 2.5.3
RUN bundle _2.5.3_ install --jobs 4

# 6. Copy the rest of the app
COPY . .

# 7. Set build argument for Rails Master Key (needed for assets precompile)
ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=$RAILS_MASTER_KEY
ENV RAILS_ENV=production

# 8. Precompile assets (skip for now, will compile on container start)
# RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# 9. Copy and set entrypoint
COPY docker-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# 10. Expose Rails port
EXPOSE 3000

# 11. Start Rails server
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-e", "production"]
