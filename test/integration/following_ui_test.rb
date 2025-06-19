require "test_helper"

class FollowingUITest < ActionDispatch::IntegrationTest
  
  def setup
    @michael = users(:michael)
    @archer = users(:archer)
    @lana = users(:lana)
  end

  test "follow button should appear and work on user profile" do
    log_in_as(@michael)
    @michael.unfollow(@archer) # Start fresh
    
    get user_path(@archer)
    
    # Should show follow button
    assert_select "form[action=?]", relationships_path do
      assert_select "input[type=submit][value=Follow]"
    end
    
    # Follow the user
    assert_difference '@michael.following.count', 1 do
      post relationships_path, params: { relationship: { followed_id: @archer.id } }
    end
    
    follow_redirect!
    
    # Should now show unfollow button
    assert_select "form[action=?]", relationship_path(@michael.active_relationships.find_by(following_id: @archer.id)) do
      assert_select "input[type=submit][value=Unfollow]"
    end
  end
  test "follow stats should update correctly" do
    log_in_as(@michael)
    
    # Get initial counts
    get user_path(@michael)
    initial_following = @michael.following.count
    
    # Follow someone
    post relationships_path, params: { relationship: { followed_id: @archer.id } }
    
    # Check updated stats on profile
    get user_path(@michael)
    assert_select "a[href=?]", following_user_path(@michael), text: /#{initial_following + 1}/
  end

  test "user cards should show correct follow state" do
    log_in_as(@michael)
    
    get users_path
    
    # Should show various states for different users
    @michael.following.each do |followed_user|
      # For followed users, should show "Following" badge
      assert_select ".user-card", text: /#{followed_user.name}/ do
        assert_select ".badge", text: "Following"
      end
    end
  end
  test "micropost follow buttons should work correctly" do
    log_in_as(@michael)
    @michael.unfollow(@archer) # Start fresh
    
    get root_path
    
    # Check if there are any microposts at all
    if page.has_css?(".micropost")
      # Look for micropost from @archer 
      if @archer.microposts.any?
        # Should show compact follow button
        assert_select ".micropost" do
          assert_select "form[action=?]", relationships_path do
            assert_select "input[value=Follow]"
          end
        end
        
        # Follow from micropost
        post relationships_path, params: { relationship: { followed_id: @archer.id } }
        
        # Check that it worked
        get root_path
        assert_select ".micropost" do
          assert_select ".badge", text: "Following"
        end
      end
    end
  end
  test "following and followers pages should display correctly" do  
    log_in_as(@michael)
    
    # Test following page
    get following_user_path(@michael)
    assert_select "h5", text: "Following (#{@michael.following.count})"
    
    @michael.following.limit(5).each do |user|
      assert_select ".user-card", text: /#{user.name}/
    end
    
    # Test followers page
    get followers_user_path(@michael)
    assert_select "h5", text: "Followers (#{@michael.followers.count})"
      @michael.followers.limit(5).each do |user|
      assert_select ".user-card", text: /#{user.name}/
    end
  end

  test "public profile should have correct elements" do
    # Test without login
    get user_path(@michael)
    
    assert_select ".badge", text: "Public Profile"
    assert_select "a[href=?]", signup_path, text: "Sign Up"
    assert_select "h2", text: @michael.name
    
    # Should show stats but not follow buttons
    assert_select ".stats"
    assert_select "input[value=Follow]", count: 0
  end

  test "own profile should have correct elements" do
    log_in_as(@michael)
    get user_path(@michael)
    
    assert_select ".badge", text: "You"
    assert_select "input[value=Follow]", count: 0
    assert_select "input[value=Unfollow]", count: 0
    
    # Should show edit profile link
    assert_select "a[href=?]", edit_user_path(@michael)
  end

  test "feed should mix different post types correctly" do
    log_in_as(@michael)
    
    # Follow some users
    @michael.follow(@archer) unless @michael.following?(@archer)
    @michael.follow(@lana) unless @michael.following?(@lana)
      get root_path
    
    # Should see microposts if they exist
    if @michael.feed.any?
      feed_posts = @michael.feed.limit(5)
      
      feed_posts.each do |post|
        # Look for micropost content (shortened)
        content_preview = post.content.truncate(20)
        if page.has_content?(content_preview)
          assert_select ".micropost", text: /#{Regexp.escape(content_preview)}/
        end
      end
    end
  end

  test "should handle follow/unfollow with flash messages" do
    log_in_as(@michael)
    @michael.unfollow(@archer) # Start fresh
    
    # Follow user
    post relationships_path, params: { relationship: { followed_id: @archer.id } }
    follow_redirect!
    
    # Should have success indication (via redirect to user)
    assert_equal user_path(@archer), path
    
    # Unfollow user
    relationship = @michael.active_relationships.find_by(following_id: @archer.id)
    delete relationship_path(relationship)
    follow_redirect!
    
    # Should redirect back to user
    assert_equal user_path(@archer), path
  end

  test "should prevent double following" do
    log_in_as(@michael)
    
    # Follow user
    @michael.follow(@archer)
    initial_count = @michael.following.count
    
    # Try to follow again
    post relationships_path, params: { relationship: { followed_id: @archer.id } }
    
    # Count should not increase
    assert_equal initial_count, @michael.reload.following.count
  end

  test "should show appropriate nav links when logged in" do
    log_in_as(@michael)
    get root_path
    
    assert_select "a[href=?]", users_path, text: "Users"
    assert_select "a[href=?]", user_path(@michael), text: "Profile" 
    assert_select "a[href=?]", logout_path
  end
end
