class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      redirect_to @user, notice: 'Welcome to the Sample App!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
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
    @user.destroy
    redirect_to users_url, notice: 'User was successfully deleted.'
  end

  private

  def set_user
    @user = User.find(params[:id])
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
end
