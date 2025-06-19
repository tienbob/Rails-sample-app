require "test_helper"

class RelationshipsControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "create should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      post relationships_path
    end
    assert_redirected_to login_url
  end

  test "destroy should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      delete relationship_path(relationships(:one))
    end
    assert_redirected_to login_url
  end

  test "should follow a user via Ajax" do
    log_in_as(@user)
    assert_difference '@user.following.count', 1 do
      post relationships_path, params: { relationship: { followed_id: @other_user.id } }
    end
  end

  test "should follow a user with standard submit" do
    log_in_as(@user)
    assert_difference '@user.following.count', 1 do
      post relationships_path, params: { relationship: { followed_id: @other_user.id } }
    end
    assert_redirected_to @other_user
  end

  test "should unfollow a user via Ajax" do
    log_in_as(@user)
    @user.follow(@other_user)
    relationship = @user.active_relationships.find_by(following_id: @other_user.id)
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship)
    end
  end

  test "should unfollow a user with standard submit" do
    log_in_as(@user)
    @user.follow(@other_user)
    relationship = @user.active_relationships.find_by(following_id: @other_user.id)
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship)
    end
    assert_redirected_to @other_user
  end

  test "should handle invalid followed_id gracefully" do
    log_in_as(@user)
    assert_no_difference 'Relationship.count' do
      post relationships_path, params: { relationship: { followed_id: 99999 } }
    end
    assert_redirected_to root_path
    assert_not flash[:error].blank?
  end
  test "should handle invalid relationship id gracefully" do
    log_in_as(@user)
    assert_no_difference 'Relationship.count' do
      delete relationship_path(99999)
    end
    assert_redirected_to root_path
    assert_not flash[:error].blank?
  end

  test "should prevent self-following" do
    log_in_as(@user)
    assert_no_difference 'Relationship.count' do
      post relationships_path, params: { relationship: { followed_id: @user.id } }
    end
    assert_redirected_to root_path
    assert_not flash[:error].blank?
  end

  test "should handle already following user gracefully" do
    log_in_as(@user)
    @user.follow(@other_user)
    initial_count = @user.following.count
    
    # Try to follow again
    post relationships_path, params: { relationship: { followed_id: @other_user.id } }
    assert_equal initial_count, @user.following.count
    assert_redirected_to @other_user
  end

  test "should handle unfollowing user not followed gracefully" do
    log_in_as(@user)
    # Make sure not following
    @user.unfollow(@other_user)
    
    # Try to unfollow non-existent relationship
    assert_no_difference '@user.following.count' do
      delete relationship_path(99999)
    end
    assert_redirected_to root_path
  end

  test "should redirect to user after successful follow" do
    log_in_as(@user)
    post relationships_path, params: { relationship: { followed_id: @other_user.id } }
    assert_redirected_to @other_user
  end

  test "should redirect to user after successful unfollow" do
    log_in_as(@user)
    @user.follow(@other_user)
    relationship = @user.active_relationships.find_by(following_id: @other_user.id)
    
    delete relationship_path(relationship)
    assert_redirected_to @other_user
  end

  test "should handle missing followed_id parameter" do
    log_in_as(@user)
    assert_no_difference 'Relationship.count' do
      post relationships_path, params: { relationship: { followed_id: nil } }
    end
    assert_redirected_to root_path
  end

  test "should handle empty relationship params" do
    log_in_as(@user)
    assert_no_difference 'Relationship.count' do
      post relationships_path, params: { relationship: {} }
    end
    assert_redirected_to root_path
  end
end
