require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest

  test "should get new" do
    get login_path
    assert_response :success
  end

  test "should create session" do
    user = users(:michael)
    post login_path, params: { session: { email: user.email, password: 'password' } }
    assert_redirected_to root_url
    assert is_logged_in?
  end

  test "should destroy session" do
    user = users(:michael)
    log_in_as(user)
    assert is_logged_in?
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
  end
end
