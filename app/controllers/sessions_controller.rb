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
    user = User.find_by(email: params[:session][:email].downcase)
    
    # Authenticate: user exists AND password matches
    # user.authenticate comes from has_secure_password in User model
    if user && user.authenticate(params[:session][:password])
      # Security: Clear any existing session data to prevent session fixation
      reset_session
      
      # These methods are defined in SessionsHelper
      log_in user              # Store user_id in session
      remember_user(user)      # Set persistent cookies for "remember me"
      redirect_to user, notice: 'Logged in successfully.'
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
end
