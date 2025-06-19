require "test_helper"

class RelationshipTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @relationship = Relationship.new(follower_id: users(:michael).id, following_id: users(:archer).id)
  end
  test "should be valid" do
    assert @relationship.valid?
  end

  test "should require a follower_id" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end

  test "should require a following_id" do
    @relationship.following_id = nil
    assert_not @relationship.valid?
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
    # Users can't follow themselves.
    michael.follow(michael)
    assert_not michael.following?(michael)
  end

  test "should destroy associated relationships when user is destroyed" do
    michael = users(:michael)
    archer = users(:archer)
    
    # Create relationships
    michael.follow(archer)
    follower_relationship = michael.active_relationships.find_by(following_id: archer.id)
    following_relationship = archer.passive_relationships.find_by(follower_id: michael.id)
    
    assert_not_nil follower_relationship
    assert_not_nil following_relationship
    
    # Destroy michael - should destroy his active relationships
    michael.destroy
    assert_nil Relationship.find_by(id: follower_relationship.id)
    assert_nil Relationship.find_by(id: following_relationship.id)
  end

  test "should prevent duplicate relationships" do
    michael = users(:michael)
    archer = users(:archer)
    
    # Clear existing relationships to avoid conflicts
    Relationship.where(follower_id: michael.id, following_id: archer.id).destroy_all
    
    # Create first relationship
    relationship1 = Relationship.new(follower_id: michael.id, following_id: archer.id)
    assert relationship1.valid?
    relationship1.save
    
    # Try to create duplicate
    relationship2 = Relationship.new(follower_id: michael.id, following_id: archer.id)
    assert_not relationship2.valid?
  end

  test "should validate uniqueness of follower_id and following_id combination" do
    michael = users(:michael)
    archer = users(:archer)
    
    # Clear existing relationships to avoid conflicts
    Relationship.where(follower_id: michael.id, following_id: archer.id).destroy_all
    
    # First relationship should be valid
    @relationship.save
    assert @relationship.valid?
    
    # Duplicate should be invalid
    duplicate = Relationship.new(follower_id: michael.id, following_id: archer.id)
    assert_not duplicate.valid?
    assert duplicate.errors[:follower_id].include?("has already been taken")
  end

  test "should belong to follower and following users" do
    assert_respond_to @relationship, :follower
    assert_respond_to @relationship, :following
    
    @relationship.save
    assert_equal users(:michael), @relationship.follower
    assert_equal users(:archer), @relationship.following
  end
end
