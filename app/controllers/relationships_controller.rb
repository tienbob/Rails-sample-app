class RelationshipsController < ApplicationController
  before_action :logged_in_user
  def create
    # Debug logging    Rails.logger.debug "Params: #{params.inspect}"
    Rails.logger.debug "followed_id from params[:followed_id]: #{params[:followed_id]}"
    Rails.logger.debug "followed_id from nested: #{params.dig(:relationship, :followed_id)}"
    
    # Handle both direct parameter and nested relationship parameter
    followed_id = params[:followed_id] || params.dig(:relationship, :followed_id)
    
    if followed_id.blank?
      flash[:error] = "No user specified to follow"
      redirect_to root_path and return
    end
    
    @user = User.find(followed_id)
    
    if @user == current_user
      flash[:error] = "You cannot follow yourself"
      redirect_to root_path and return
    end
    
    current_user.follow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.turbo_stream
    end
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "User not found"
    redirect_to root_path
  end

  def destroy
    @user = Relationship.find(params[:id]).following
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.turbo_stream
    end
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Relationship not found"
    redirect_to root_path
  end

  private

  def relationship_params
    params.require(:relationship).permit(:followed_id) if params[:relationship]
  end
end
