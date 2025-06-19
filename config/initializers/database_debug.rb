# Debug database configuration in production
if Rails.env.production?
  Rails.application.config.after_initialize do
    begin
      puts "=== DATABASE CONFIGURATION DEBUG ==="
      puts "Rails.env: #{Rails.env}"
      puts "DATABASE_URL present: #{ENV['DATABASE_URL'] ? 'YES' : 'NO'}"
      puts "DATABASE_URL length: #{ENV['DATABASE_URL']&.length || 0}"
      
      if ENV['DATABASE_URL']
        # Parse DATABASE_URL to show components without exposing credentials
        uri = URI.parse(ENV['DATABASE_URL'])
        puts "Database host: #{uri.host}"
        puts "Database port: #{uri.port}"
        puts "Database name: #{uri.path[1..-1]}" # Remove leading slash
        puts "Database user: #{uri.user}"
      end
      
      config = ActiveRecord::Base.connection_config
      puts "Active connection config:"
      puts "  adapter: #{config[:adapter]}"
      puts "  host: #{config[:host]}"
      puts "  port: #{config[:port]}"
      puts "  database: #{config[:database]}"
      puts "===================================="
    rescue => e
      puts "Database debug error: #{e.message}"
    end
  end
end
