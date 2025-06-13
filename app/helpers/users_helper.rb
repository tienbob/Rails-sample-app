module UsersHelper
  def gravatar_for(user, options = {})
    size = options[:size] || 80
    css_class = options[:class] || "gravatar"
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    gravatar_url = "https://www.gravatar.com/avatar/#{gravatar_id}?s=#{size}&d=identicon"
    image_tag(gravatar_url, alt: user.name, class: css_class)
  end
end
