require "test_helper"

class AuthorizationTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "should redirect to login when accessing following page without login" do
    get following_user_path(@user)
    assert_redirected_to login_url
    assert_not flash.empty?
  end

  test "should redirect to login when accessing followers page without login" do  
    get followers_user_path(@user)
    assert_redirected_to login_url
    assert_not flash.empty?
  end

  test "should redirect to login when trying to create relationship without login" do
    assert_no_difference 'Relationship.count' do
      post relationships_path, params: { relationship: { followed_id: @other_user.id } }
    end
    assert_redirected_to login_url
  end

  test "should redirect to login when trying to destroy relationship without login" do
    # Create a relationship first
    log_in_as(@user)
    @user.follow(@other_user)
    relationship = @user.active_relationships.find_by(following_id: @other_user.id)
    delete logout_path
    
    # Try to delete without being logged in
    assert_no_difference 'Relationship.count' do
      delete relationship_path(relationship)
    end
    assert_redirected_to login_url
  end

  test "should allow access to public profile without login" do
    get user_path(@user)
    assert_response :success
    assert_select ".badge", text: "Public Profile"
  end

  test "logged in users should not see New User button on index" do
    log_in_as(@user)
    get users_path
    assert_select "a[href=?]", new_user_path, count: 0
  end
  test "non-logged users should see signup link on public profiles" do
    get user_path(@user)
    assert_select "a[href=?]", signup_path, text: "Sign Up"
  end

  test "should not allow following yourself" do
    log_in_as(@user)
    
    assert_no_difference '@user.following.count' do
      post relationships_path, params: { relationship: { followed_id: @user.id } }
    end
    
    assert_redirected_to root_path
    assert_not flash[:error].blank?
  end

  test "should handle unauthorized relationship deletion gracefully" do
    log_in_as(@user)
    @user.follow(@other_user)
    relationship = @user.active_relationships.find_by(following_id: @other_user.id)
    
    # Log in as different user and try to delete relationship
    log_in_as(@other_user)
    
    assert_no_difference 'Relationship.count' do
      delete relationship_path(relationship)
    end
    
    # The relationship should still exist
    assert_not_nil Relationship.find_by(id: relationship.id)
  end

  test "should require proper authorization for user edit/update" do
    # Try to edit other user's profile
    log_in_as(@other_user)
    
    get edit_user_path(@user)
    assert_redirected_to root_url
    
    patch user_path(@user), params: { user: { name: "Changed Name" } }
    assert_redirected_to root_url
    
    # User's name should not have changed
    assert_not_equal "Changed Name", @user.reload.name
  end
end
