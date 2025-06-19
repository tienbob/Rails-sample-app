require "test_helper"

class MicropostTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup

    @User = users(:michael)
    @Micropost = @User.microposts.build(content: "bruh")
    @User_2 = User.new(name: "bruh", password: "Lmao123", password_confirmation: "Lmao123", email: "bruh@lmao.com")
  end

  test "should be valid" do
    assert @Micropost.valid?
  end
  test "user id should be present" do
    @Micropost.user_id = nil
    assert_not @Micropost.valid?
  end
  test "content should be present" do
    @Micropost.content = "   "
    assert_not @Micropost.valid?
  end
  test "content should be at most 140 characters" do
    @Micropost.content = "a" * 141
    assert_not @Micropost.valid?
  end
  test "order must be order by most recent first" do
    assert_equal microposts(:most_recent), Micropost.first 
  end

  test "micropost must be destroy with user" do
    @User_2.save
    @User_2.microposts.create(content: "lorem ipsum")
    assert_difference "Micropost.count", -1 do
      @User_2.destroy
    end
  end
end
