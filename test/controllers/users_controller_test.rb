require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get new_user_path
    assert_response :success
  end

  test "should get index" do
    log_in_as(@user)
    get users_path
    assert_response :success
  end

  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  test "should show user profile" do
    get user_path(@other_user)
    assert_response :success
    assert_select "title", "#{@other_user.name}"
  end

  test "should show public profile for other users" do
    log_in_as(@user)
    get user_path(@other_user)
    assert_response :success
    assert_select ".badge", text: "Public Profile"
  end

  test "should show full profile for own profile" do
    log_in_as(@user)
    get user_path(@user)
    assert_response :success
    assert_select ".badge", text: "You"
  end

  test "should get following" do
    log_in_as(@user)
    get following_user_path(@user)
    assert_response :success
  end

  test "should get followers" do
    log_in_as(@user)
    get followers_user_path(@user)
    assert_response :success
  end

  test "following should require logged-in user" do
    get following_user_path(@user)
    assert_redirected_to login_url
  end

  test "followers should require logged-in user" do
    get followers_user_path(@user)
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch user_path(@user), params: { user: { name: @user.name, email: @user.email } }
    assert_redirected_to login_url
  end

  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name, email: @user.email } }
    assert_redirected_to root_url
  end

  test "should show correct profile badge for different users" do
    # Test own profile
    log_in_as(@user)
    get user_path(@user)
    assert_select ".badge", text: "You"
    
    # Test other user's profile when logged in
    get user_path(@other_user)
    assert_select ".badge", text: "Public Profile"
  end

  test "should show public profile for non-logged users" do
    get user_path(@user)
    assert_response :success
    assert_select ".badge", text: "Public Profile"
    assert_select "a[href=?]", signup_path
  end

  test "should display user stats correctly" do
    log_in_as(@user)
    get user_path(@user)
    
    # Check that microposts, following, followers counts are displayed
    assert_match @user.microposts.count.to_s, response.body
    assert_match @user.following.count.to_s, response.body
    assert_match @user.followers.count.to_s, response.body
  end

  test "should show follow form for other users when logged in" do
    log_in_as(@user)
    @user.unfollow(@other_user) # Make sure not following
    
    get user_path(@other_user)
    assert_select "input[value='Follow']"
  end

  test "should show unfollow form when already following" do
    log_in_as(@user)
    @user.follow(@other_user)
    
    get user_path(@other_user)
    assert_select "input[value='Unfollow']"
  end

  test "should not show follow form on own profile" do
    log_in_as(@user)
    get user_path(@user)
    assert_select "input[value='Follow']", count: 0
    assert_select "input[value='Unfollow']", count: 0
  end

  test "following page should paginate results" do
    log_in_as(@user)
    get following_user_path(@user)
    assert_response :success
    if @user.following.count > 20
      assert_select "div.pagination", count: 1 
    end
  end

  test "followers page should paginate results" do
    log_in_as(@user)
    get followers_user_path(@user)
    assert_response :success
    if @user.followers.count > 20
      assert_select "div.pagination", count: 1 
    end
  end

  test "should handle invalid user id for following page" do
    log_in_as(@user)
    get following_user_path(99999)
    assert_response :redirect
    assert_redirected_to root_path
  end

  test "should handle invalid user id for followers page" do
    log_in_as(@user)
    get followers_user_path(99999)
    assert_response :redirect
    assert_redirected_to root_path
  end

  test "index should not show New User button for logged in users" do
    log_in_as(@user)
    get users_path
    assert_select "a[href=?]", new_user_path, count: 0
  end
end
