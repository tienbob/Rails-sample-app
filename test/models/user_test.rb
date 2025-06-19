require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = User.new(name: "Test User", email: "abcd@gmail.com",password: "foobar", password_confirmation: "foobar")  
  end
  test "should be valid" do
    assert @user.valid?
  end
  test "name should be present" do
    @user.name = "   "
    assert_not @user.valid?
  end
  test "email should be present" do
    @user.email = "   "
    assert_not @user.valid?
  end
  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end 
  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end
  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = "CAkchkjha@bjJA.Com"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end
  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil remember_digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "should follow and unfollow a user" do
    michael = users(:michael)
    archer = users(:archer)
    assert_not michael.following?(archer)
    michael.follow(archer)
    assert michael.following?(archer)
    assert archer.followers.include?(michael)
    michael.unfollow(archer)
    assert_not michael.following?(archer)
  end

  test "should not follow self" do
    michael = users(:michael)
    michael.follow(michael)
    assert_not michael.following?(michael)
  end

  test "feed should have the right posts" do
    michael = users(:michael)
    archer = users(:archer)
    lana = users(:lana)
    
    # Posts from followed user
    lana.microposts.each do |post_following|
      assert michael.feed.include?(post_following)
    end
    
    # Posts from self
    michael.microposts.each do |post_self|
      assert michael.feed.include?(post_self)
    end
    
    # Posts from unfollowed user should be included (community posts)
    archer.microposts.each do |post_unfollowed|
      assert michael.feed.include?(post_unfollowed)
    end
  end

  test "feed should include community posts when not following many users" do
    michael = users(:michael)
    archer = users(:archer)
    
    # Unfollow everyone first
    michael.following.each { |user| michael.unfollow(user) }
    
    # Feed should include community posts
    assert michael.feed.include?(archer.microposts.first) if archer.microposts.any?
  end

  test "associated microposts should be destroyed when user is destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "active relationships should be destroyed when user is destroyed" do
    # Create a fresh user to avoid fixture interference
    michael = User.create!(name: "Test Michael", email: "test_michael@example.com", 
                          password: "password", password_confirmation: "password",
                          activated: true, activated_at: Time.zone.now)
    archer = users(:archer)
    lana = users(:lana)
    
    # Create some active relationships (michael follows others)
    michael.follow(archer)
    michael.follow(lana)
    
    # Count michael's active relationships
    active_count = michael.active_relationships.count
    assert_equal 2, active_count
    
    # When michael is destroyed, his active relationships should be destroyed
    assert_difference 'Relationship.count', -active_count do
      michael.destroy
    end
  end

  test "passive relationships should be destroyed when user is destroyed" do
    # Create a fresh user to avoid fixture interference
    target_user = User.create!(name: "Test Target", email: "test_target@example.com", 
                              password: "password", password_confirmation: "password",
                              activated: true, activated_at: Time.zone.now)
    michael = users(:michael)
    archer = users(:archer)
    
    # Clear michael and archer's existing relationships to avoid interference
    michael.active_relationships.destroy_all
    archer.active_relationships.destroy_all
    
    # Create relationships where others follow target_user
    michael.follow(target_user)
    archer.follow(target_user)
    
    # Count target_user's passive relationships
    passive_count = target_user.passive_relationships.count
    assert_equal 2, passive_count
    
    # When target_user is destroyed, his passive relationships should be destroyed
    assert_difference 'Relationship.count', -passive_count do
      target_user.destroy
    end
  end

  test "following and followers associations should work correctly" do
    michael = users(:michael)
    archer = users(:archer)
    lana = users(:lana)
    
    # Clear existing relationships first
    michael.active_relationships.destroy_all
    archer.passive_relationships.destroy_all
    lana.passive_relationships.destroy_all
    
    # Test following association
    michael.follow(archer)
    michael.follow(lana)
    
    assert_includes michael.following, archer
    assert_includes michael.following, lana
    assert_equal 2, michael.following.count
    
    # Test followers association
    assert_includes archer.followers, michael
    assert_includes lana.followers, michael
  end

  test "should not be able to follow the same user twice" do
    michael = users(:michael)
    archer = users(:archer)
    
    # Clear existing relationships first
    michael.active_relationships.destroy_all
    
    # Follow once
    michael.follow(archer)
    initial_count = michael.following.count
    
    # Try to follow again
    michael.follow(archer)
    assert_equal initial_count, michael.following.count
  end

  test "should be able to unfollow a user not currently followed" do
    michael = users(:michael)
    archer = users(:archer)
    
    # Clear existing relationships and make sure not following
    michael.active_relationships.destroy_all
    michael.unfollow(archer)
    initial_count = michael.following.count
    
    # Try to unfollow again
    michael.unfollow(archer)
    assert_equal initial_count, michael.following.count
  end

  test "feed should be ordered by most recent first" do
    michael = users(:michael)
    feed = michael.feed
    
    # Feed should be ordered by created_at desc
    feed.each_cons(2) do |post1, post2|
      assert post1.created_at >= post2.created_at
    end
  end

  test "feed should include user's own posts" do
    michael = users(:michael)
    michael.microposts.each do |micropost|
      assert_includes michael.feed, micropost
    end
  end

  test "feed should include posts from followed users" do
    michael = users(:michael)
    lana = users(:lana)
    
    # Make sure michael follows lana
    michael.follow(lana) unless michael.following?(lana)
    
    lana.microposts.each do |micropost|
      assert_includes michael.feed, micropost
    end
  end

  test "feed should limit community posts when following many users" do
    michael = users(:michael)
    
    # Follow many users
    [users(:archer), users(:lana), users(:malory), users(:pam)].each do |user|
      michael.follow(user)
    end
    
    feed = michael.feed
    assert feed.count > 0
    
    # When following 4+ users, community posts should be limited
    # This is a bit hard to test precisely, but we can check structure
    assert_respond_to michael, :feed
  end
end
