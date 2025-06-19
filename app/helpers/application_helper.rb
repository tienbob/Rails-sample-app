module ApplicationHelper
  include SessionsHelper
  
  def full_title(title = "")
    base_title = "Sample App"
    if title.empty?
      base_title
    else
      "#{title} | #{base_title}"
    end
  end

  # Returns the Gravatar for the given user.
  def gravatar_for(user, options = { size: 80 })
    size = options[:size]
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar rounded-circle")
  end

  # Enhanced pagination helper with better styling
  def enhanced_paginate(collection, options = {})
    default_options = {
      class: "pagination justify-content-center mb-0",
      previous_label: "← Previous",
      next_label: "Next →",
      inner_window: 2,
      outer_window: 1
    }
    
    will_paginate(collection, default_options.merge(options))
  end

  # Pagination info helper
  def pagination_info(collection)
    if collection.respond_to?(:total_entries)
      total = collection.total_entries
      per_page = collection.per_page
      current_page = collection.current_page
      
      start_item = (current_page - 1) * per_page + 1
      end_item = [current_page * per_page, total].min
      
      content_tag :small, class: "text-muted d-block text-center mt-2" do
        "Showing #{start_item}-#{end_item} of #{total} #{collection.model.name.downcase.pluralize}"
      end
    end
  end
end
