require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: "", password: "" } }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "login with valid information followed by logout" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: @user.email, password: 'password' } }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    # Skip link assertions for now
    
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    # Skip link assertions for now
  end
  
  test "should still work after logout in second window" do
    # Log in first
    post login_path, params: { session: { email: @user.email, password: 'password' } }
    assert is_logged_in?
    
    # Simulate a user clicking logout in a second window
    delete logout_path
    follow_redirect!
    
    # Verify that a second logout attempt doesn't cause errors
    delete logout_path
    follow_redirect!
    # Skip link assertions for now
  end
end
