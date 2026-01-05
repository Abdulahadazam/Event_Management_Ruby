namespace :render do
  desc "Setup database for Render deployment"
  task :setup => :environment do
    begin
      # Enable PostGIS extension if not already enabled
      ActiveRecord::Base.connection.execute("CREATE EXTENSION IF NOT EXISTS postgis")
      puts "✓ PostGIS extension enabled"
    rescue => e
      puts "⚠ Warning: Could not enable PostGIS extension: #{e.message}"
      puts "  This may need to be done manually in Render's database settings"
    end

    # Run migrations
    Rake::Task["db:migrate"].invoke
    puts "✓ Database migrations complete"

    puts "✅ Database setup complete!"
  end
end
