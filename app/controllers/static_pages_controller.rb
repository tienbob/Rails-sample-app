class StaticPagesController < ApplicationController
  def home
    if logged_in?
      @micropost = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page], per_page: 3)
    end
  end

  def help
  end

  def about
  end

  def contact
  end

  # Temporary debug endpoint to test database connectivity
  def debug_db
    begin
      env_info = {
        rails_env: Rails.env,
        database_url_present: ENV['DATABASE_URL'] ? 'YES' : 'NO',
        database_url_length: ENV['DATABASE_URL']&.length || 0
      }
      
      # Parse DATABASE_URL if present
      if ENV['DATABASE_URL']
        uri = URI.parse(ENV['DATABASE_URL'])
        env_info[:db_host] = uri.host
        env_info[:db_port] = uri.port
        env_info[:db_name] = uri.path[1..-1] # Remove leading slash
        env_info[:db_user] = uri.user
      end
      
      connection_info = {
        adapter: ActiveRecord::Base.connection.adapter_name,
        database: ActiveRecord::Base.connection.current_database,
        config: ActiveRecord::Base.connection_config.except(:password)
      }
      
      counts = {
        user_count: User.count,
        micropost_count: Micropost.count
      }
      
      render json: { 
        status: 'success', 
        message: 'Database connection working',
        environment: env_info,
        connection: connection_info,
        counts: counts
      }
    rescue => e
      render json: { 
        status: 'error', 
        message: e.message,
        backtrace: e.backtrace.first(10),
        environment: {
          rails_env: Rails.env,
          database_url_present: ENV['DATABASE_URL'] ? 'YES' : 'NO',
          database_url_length: ENV['DATABASE_URL']&.length || 0
        }
      }
    end
  end
end
