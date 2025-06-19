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
      connection_info = {
        adapter: ActiveRecord::Base.connection.adapter_name,
        database: ActiveRecord::Base.connection.current_database,
        user_count: User.count,
        micropost_count: Micropost.count
      }
      render json: { 
        status: 'success', 
        message: 'Database connection working',
        info: connection_info
      }
    rescue => e
      render json: { 
        status: 'error', 
        message: e.message,
        backtrace: e.backtrace.first(5)
      }
    end
  end
end
