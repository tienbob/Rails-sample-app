class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  before_action :set_user, only: [:show, :edit, :update, :destroy, :public_profile, :following, :followers]

  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def new
    @user = User.new
  end
  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find(params[:id])
    # Ensure the user is activated before showing their profile
    unless @user.activated?
      flash[:warning] = "Account not activated."
      redirect_to root_url, status: :see_other and return
    end
    
    @microposts = @user.microposts.paginate(page: params[:page], per_page: 3)
    
    # Determine if this is the user's own profile or someone else's
    if current_user?(@user)
      # Show full profile for own profile
      render :show
    else
      # Show public profile for other users
      render :public_profile
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    # Use user_params_for_update to handle password updates correctly
    if @user.update(user_params_for_update)
      flash[:success] = 'Your profile was successfully updated.'
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url, status: :see_other
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private    def set_user
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "User not found"
      redirect_to root_path
    end

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def user_params_for_update
      if params[:user][:password].blank?
        params.require(:user).permit(:name, :email)
      else
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end
    end

    # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url, status: :see_other) unless current_user?(@user)
    end

    # Confirms an admin user.
    def admin_user
      redirect_to(root_url, status: :see_other) unless current_user.admin?
    end
end
