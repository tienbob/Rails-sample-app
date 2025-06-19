require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "full_title helper" do
    assert_equal full_title, "Sample App"
    assert_equal full_title("Help"), "Help | Sample App"
  end

  test "gravatar_for helper should generate gravatar image" do
    gravatar_html = gravatar_for(@user)
    
    assert_includes gravatar_html, 'gravatar'  
    assert_includes gravatar_html, 'img'
    # Check for the gravatar hash instead of raw email
    email_hash = Digest::MD5::hexdigest(@user.email.downcase)
    assert_includes gravatar_html, email_hash
  end

  test "gravatar_for helper should accept size option" do
    gravatar_html = gravatar_for(@user, size: 80)
    
    assert_includes gravatar_html, 's=80'
  end

  test "gravatar_for helper should handle email hashing correctly" do
    gravatar_html = gravatar_for(@user)
    
    # Should include MD5 hash of email
    email_hash = Digest::MD5::hexdigest(@user.email.downcase)
    assert_includes gravatar_html, email_hash
  end
end
