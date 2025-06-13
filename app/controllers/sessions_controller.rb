class SessionsController < ApplicationController
  def new
  end
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      reset_session # Clear any existing session
      log_in user
      redirect_to user, notice: 'Logged in successfully.'
    else
      flash.now[:alert] = 'Invalid email/password combination'
      render :new, status: :unprocessable_entity
    end
  end
  def destroy
    log_out if logged_in?
    redirect_to root_path, notice: 'Logged out successfully.'
  end
end
