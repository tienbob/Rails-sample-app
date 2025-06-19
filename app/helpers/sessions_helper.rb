module SessionsHelper
  # RAILS MAGIC: Helper modules are automatically included in controllers and views
  # This means all these methods are available in controllers and view templates

  # Logs in the given user by storing their ID in the session
  # RAILS MAGIC: session is a special hash that persists across requests
  # Rails automatically encrypts and signs session data for security
  def log_in(user)
    session[:user_id] = user.id
    # Guard against session replay attacks.
    # See https://bit.ly/33UvK0w for more.
    session[:session_token] = user.id
  end

  # Remembers a user in a persistent session.
  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Returns the current logged-in user (if any)
  # This method handles BOTH temporary sessions AND permanent "remember me" cookies
  def current_user
    # TEMPORARY LOGIN: Check if user_id exists in session (normal login)
    if session[:user_id]
      # ||= means "assign only if @current_user is nil"
      # This caches the user lookup so we don't hit database repeatedly
      @current_user ||= User.find_by(id: session[:user_id])
      
    # PERMANENT LOGIN: Check encrypted cookies for "remember me" functionality
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      
      # Verify the remember token matches what's stored in database
      # This is where your authenticated? method gets used!
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user  # Convert cookie login to session login
        @current_user = user
      end
    end
  end

  # Returns true if the given user is the current user.
  def current_user?(user)
    user && user == current_user
  end

  # Returns true if the user is logged in, false otherwise
  # Simply checks if current_user returns something or nil
  def logged_in?
    !current_user.nil?
  end

  # Logs out the current user completely
  def log_out
    # Clean up remember cookies if user is logged in
    forget(current_user) if logged_in?
    
    # Clear the session data
    session.delete(:user_id)
    
    # Clear the cached user instance
    @current_user = nil
  end

  # "Remember" a user with persistent cookies for automatic login
  def remember_user(user)
    # Generate and store remember token in user object and database
    user.remember  # This calls the remember method in User model
    
    # Set persistent cookies (they survive browser restart)
    # .permanent makes cookies last 20 years
    # .encrypted protects the user_id from tampering
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # "Forget" a user by clearing their remember cookies and database digest
  def forget(user)
    # Clear the remember_digest from database
    user.forget  # This calls the forget method in User model
    
    # Delete the cookies
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

  # Redirects to stored location (or to the default).
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default, status: :see_other)
    session.delete(:forwarding_url)
  end
end