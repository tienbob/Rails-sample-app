class SessionsController < ApplicationController
  # RAILS MAGIC: ApplicationController gives us access to:
  # - Helper methods from all helpers (including SessionsHelper)
  # - Built-in methods like params, session, cookies, redirect_to, etc.
  # - Flash messages, before_action callbacks, etc.

  # GET /login - Shows the login form
  def new
    # Nothing needed here - just renders app/views/sessions/new.html.erb
  end

  # POST /login - Processes the login form submission
  def create
    # Find user by email (params comes from the form submission)
    # params[:session][:email] comes from form field name="session[email]"
    email = params[:session]&.[](:email)
    password = params[:session]&.[](:password)
    
    # Check if email and password are present
    if email.blank? || password.blank?
      flash.now[:alert] = 'Email and password cannot be blank'
      render :new, status: :unprocessable_entity
      return
    end
    
    user = User.find_by(email: email.downcase.strip)
      # Authenticate: user exists AND password matches
    # user.authenticate comes from has_secure_password in User model
    if user && user.authenticate(password)
      if user.activated?
        # Security: Clear any existing session data to prevent session fixation
        reset_session
        
        # These methods are defined in SessionsHelper
        log_in user              # Store user_id in session
        remember_user(user)      # Set persistent cookies for "remember me"
        redirect_back_or(root_url)
      else
        message = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      # flash.now makes flash message available only for this render
      # (regular flash would persist to next request)
      flash.now[:alert] = 'Invalid email/password combination'
      render :new, status: :unprocessable_entity
    end
  end
  
  # DELETE /logout - Logs out the user
  def destroy
    # Only log out if user is currently logged in (safety check)
    log_out if logged_in?  # Both methods from SessionsHelper
    redirect_to root_url, notice: 'Logged out successfully.'
  end

  # Temporary debug action for production troubleshooting
  def debug_info
    if Rails.env.production?
      render json: {
        rails_env: Rails.env,
        database_url_present: ENV['DATABASE_URL'].present?,
        user_count: User.count,
        session_helper_included: ApplicationController.included_modules.include?(SessionsHelper),
        current_time: Time.current
      }
    else
      redirect_to root_path
    end
  rescue => e
    render json: { error: e.message, backtrace: e.backtrace.first(5) }
  end
end
