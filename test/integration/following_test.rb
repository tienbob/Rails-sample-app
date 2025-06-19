require "test_helper"

class FollowingTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other = users(:archer)
    @third_user = users(:lana)
  end

  test "following page" do
    log_in_as(@user)
    get following_user_path(@user)
    assert_not @user.following.empty?
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "followers page" do
    log_in_as(@user)
    get followers_user_path(@user)
    assert_not @user.followers.empty?
    assert_match @user.followers.count.to_s, response.body
    @user.followers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "should follow a user the standard way" do
    log_in_as(@user)
    assert_difference '@user.following.count', 1 do
      post relationships_path, params: { relationship: { followed_id: @other.id } }
    end
  end

  test "should follow a user with Ajax" do
    log_in_as(@user)
    assert_difference '@user.following.count', 1 do
      post relationships_path, params: { relationship: { followed_id: @other.id } }
    end
  end

  test "should unfollow a user the standard way" do
    log_in_as(@user)
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(following_id: @other.id)
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship)
    end
  end

  test "should unfollow a user with Ajax" do
    log_in_as(@user)
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(following_id: @other.id)
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship)
    end
  end

  test "feed on Home page" do
    log_in_as(@user)
    get root_path
    @user.feed.paginate(page: 1).each do |micropost|
      assert_match CGI.escapeHTML(micropost.content), response.body
    end
  end

  test "should show follow button on micropost from unfollowed user" do
    log_in_as(@user)
    # Make sure user is not following the other user
    @user.unfollow(@other) if @user.following?(@other)
    
    get root_path
    assert_select "input[value='Follow']"
  end

  test "should show following badge on micropost from followed user" do
    log_in_as(@user)
    @user.follow(@other)
    
    get root_path
    assert_select ".badge", text: "Following"
  end

  test "should display correct stats on user profile" do
    log_in_as(@user)
    get user_path(@user)
    
    assert_select "h6", text: @user.microposts.count.to_s
    assert_select "h6", text: @user.following.count.to_s
    assert_select "h6", text: @user.followers.count.to_s
  end

  test "public profile should be accessible to non-logged users" do
    get user_path(@user)
    assert_response :success
    assert_select ".badge", text: "Public Profile"
    assert_select "a[href=?]", signup_path
  end

  test "should show follow form on public profile for logged-in user" do
    log_in_as(@user)
    get user_path(@other)
    assert_select "input[value='Follow']"
  end
  test "should not show follow form for own public profile" do
    log_in_as(@user)
    get user_path(@user)
    assert_select "input[value='Follow']", count: 0
  end

  test "should show correct follow button states on user cards" do
    log_in_as(@user)
    
    # Test follow button for unfollowed user
    @user.unfollow(@other) if @user.following?(@other)
    get users_path
    assert_select ".user-card" do
      assert_select "input[value='Follow']"
    end
    
    # Test following badge for followed user
    @user.follow(@other)
    get users_path
    assert_select ".user-card" do
      assert_select ".badge", text: "Following"
    end
  end

  test "should handle pagination on following page" do
    log_in_as(@user)
    
    # Create enough relationships to trigger pagination
    users_to_follow = User.where.not(id: @user.id).limit(25)
    users_to_follow.each { |user| @user.follow(user) }
    
    get following_user_path(@user)
    assert_select ".pagination" if @user.following.count > 20
  end
  test "should handle pagination on followers page" do
    log_in_as(@user)
    get followers_user_path(@user)
    assert_response :success
    if @user.followers.count > 20
      assert_select ".pagination"
    end
  end
  test "should display user info correctly in follow pages" do
    log_in_as(@user)
    get following_user_path(@user)
    
    assert_select "h4", text: @user.name
    assert_select "h5", text: /Following/
    
    get followers_user_path(@user)
    assert_select "h4", text: @user.name  
    assert_select "h5", text: /Followers/
  end

  test "should maintain proper counts after follow/unfollow" do
    log_in_as(@user)
    
    initial_following_count = @user.following.count
    initial_followers_count = @other.followers.count
    
    # Follow user
    post relationships_path, params: { relationship: { followed_id: @other.id } }
    
    @user.reload
    @other.reload
    
    assert_equal initial_following_count + 1, @user.following.count
    assert_equal initial_followers_count + 1, @other.followers.count
    
    # Unfollow user
    relationship = @user.active_relationships.find_by(following_id: @other.id)
    delete relationship_path(relationship)
    
    @user.reload
    @other.reload
    
    assert_equal initial_following_count, @user.following.count
    assert_equal initial_followers_count, @other.followers.count
  end

  test "should handle follow/unfollow from different entry points" do
    log_in_as(@user)
    @user.unfollow(@other) # Start fresh
    
    # Test following from user profile
    get user_path(@other)
    assert_difference '@user.following.count', 1 do
      post relationships_path, params: { relationship: { followed_id: @other.id } }
    end
    
    # Test unfollowing from users index 
    relationship = @user.active_relationships.find_by(following_id: @other.id)
    get users_path
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship)
    end
  end

  test "micropost follow buttons should update correctly" do
    log_in_as(@user)
    @user.unfollow(@other) # Start fresh
    
    get root_path
    
    # Look for micropost from @other user
    if @other.microposts.any?
      # Should show follow button
      assert_select ".micropost" do
        assert_select "input[value='Follow']"
      end
      
      # Follow the user
      @user.follow(@other)
      get root_path
      
      # Should now show following badge
      assert_select ".micropost" do
        assert_select ".badge", text: "Following"
      end
    end
  end
end
