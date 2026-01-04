namespace :render do
  desc "Setup database for Render deployment"
  task :setup do
    # Run migrations
    Rake::Task["db:migrate"].invoke

    # Enable PostGIS extension if not already enabled
    ActiveRecord::Base.connection.execute("CREATE EXTENSION IF NOT EXISTS postgis")

    puts "Database setup complete!"
  end
end
