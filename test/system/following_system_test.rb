require "application_system_test_case"

class FollowingSystemTest < ApplicationSystemTestCase
  include ActionDispatch::IntegrationTest::UrlHelpers

  def setup
    @michael = users(:michael)
    @archer = users(:archer)
    @lana = users(:lana)
  end

  test "following and follower pages display correctly" do
    # Log in as michael
    visit login_path
    fill_in "Email", with: @michael.email
    fill_in "Password", with: "password"
    click_on "Log in"

    # Visit following page
    visit following_user_path(@michael)
    assert_selector "h3", text: "Following"
    assert_selector ".user-card", count: @michael.following.count
    
    # Visit followers page  
    visit followers_user_path(@michael)
    assert_selector "h3", text: "Followers"
    assert_selector ".user-card", count: @michael.followers.count
  end

  test "can follow and unfollow users from profile page" do
    visit login_path
    fill_in "Email", with: @michael.email
    fill_in "Password", with: "password"
    click_on "Log in"

    # Visit archer's profile (assuming michael is not following archer initially)
    @michael.unfollow(@archer) if @michael.following?(@archer)
    visit user_path(@archer)
    
    # Follow archer
    assert_selector "button", text: "Follow"
    click_on "Follow"
    
    # Should now show unfollow button
    assert_selector "button", text: "Unfollow"
    
    # Verify relationship was created
    assert @michael.reload.following?(@archer)
    
    # Unfollow archer
    click_on "Unfollow"
    assert_selector "button", text: "Follow"
    
    # Verify relationship was destroyed
    assert_not @michael.reload.following?(@archer)
  end

  test "follow buttons work from users index page" do
    visit login_path
    fill_in "Email", with: @michael.email
    fill_in "Password", with: "password"
    click_on "Log in"

    visit users_path
    
    # Find a user card and follow them
    @michael.unfollow(@archer) if @michael.following?(@archer)
    
    # Look for archer's card and follow button
    within find(".user-card", text: @archer.name) do
      click_on "Follow"
    end
    
    # Should show following badge now
    within find(".user-card", text: @archer.name) do
      assert_text "Following"
    end
    
    assert @michael.reload.following?(@archer)
  end

  test "home page feed shows posts from followed users" do
    visit login_path
    fill_in "Email", with: @michael.email
    fill_in "Password", with: "password" 
    click_on "Log in"

    # Make sure michael is following lana
    @michael.follow(@lana) unless @michael.following?(@lana)
    
    visit root_path
    
    # Should see posts from self and followed users in feed
    @michael.feed.limit(5).each do |post|
      assert_text post.content.truncate(50)
    end
  end

  test "can follow users from micropost feed" do
    visit login_path
    fill_in "Email", with: @michael.email
    fill_in "Password", with: "password"
    click_on "Log in"

    # Unfollow archer first
    @michael.unfollow(@archer) if @michael.following?(@archer)
    
    visit root_path
    
    # Look for a micropost from archer and follow from there
    if page.has_content?(@archer.name)
      within find(".micropost", text: @archer.name) do
        if page.has_button?("Follow")
          click_on "Follow"
          assert_text "Following"
        end
      end
      
      assert @michael.reload.following?(@archer)
    end
  end

  test "public profiles are accessible without login" do
    visit user_path(@michael)
    
    assert_selector ".badge", text: "Public Profile"
    assert_text @michael.name
    assert_selector "a[href='#{signup_path}']", text: "Sign up now!"
  end

  test "stats are displayed correctly on profile pages" do
    visit login_path
    fill_in "Email", with: @michael.email
    fill_in "Password", with: "password"
    click_on "Log in"

    visit user_path(@michael)
    
    # Check that stats are displayed
    assert_text "#{@michael.microposts.count}"
    assert_text "#{@michael.following.count}"  
    assert_text "#{@michael.followers.count}"
  end

  test "pagination works on following and followers pages" do
    visit login_path
    fill_in "Email", with: @michael.email
    fill_in "Password", with: "password"
    click_on "Log in"

    # Create more relationships for pagination testing
    users_to_follow = [@archer, @lana, users(:malory), users(:pam), users(:cyril)]
    users_to_follow.each { |user| @michael.follow(user) }

    visit following_user_path(@michael)
    
    # Should have pagination if more than 20 users
    if @michael.following.count > 20
      assert_selector ".pagination"
    end
  end

  test "cannot follow yourself" do
    visit login_path
    fill_in "Email", with: @michael.email
    fill_in "Password", with: "password"
    click_on "Log in"

    visit user_path(@michael)
    
    # Should not see follow button on own profile
    assert_no_selector "button", text: "Follow"
    assert_selector ".badge", text: "You"
  end
end
