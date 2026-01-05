#!/bin/bash
set -e

# Precompile assets if they don't exist
if [ ! -d "public/assets" ]; then
  echo "Precompiling assets..."
  bundle exec rails assets:precompile
fi

# Run database migrations (optional, commented out for safety)
# bundle exec rails db:migrate

# Start the Rails server
exec "$@"
