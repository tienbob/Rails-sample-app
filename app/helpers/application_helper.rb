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

  # Enhanced pagination helper with Bootstrap 5 styling
  def enhanced_paginate(collection, options = {})
    default_options = {
      previous_label: raw('<i class="fas fa-chevron-left me-1"></i>Previous'),
      next_label: raw('Next<i class="fas fa-chevron-right ms-1"></i>'),
      inner_window: 2,
      outer_window: 1,
      class: "pagination justify-content-center mb-0"
    }
    
    # Use will_paginate with custom CSS classes
    pagination_html = will_paginate(collection, default_options.merge(options))
    
    if pagination_html
      # Wrap in Bootstrap nav structure and apply Bootstrap classes
      content_tag :nav, 'aria-label': 'Pagination Navigation' do
        pagination_html.gsub(/<div class="pagination[^"]*">/, '<ul class="pagination justify-content-center mb-0">')
                      .gsub(/<\/div>/, '</ul>')
                      .gsub(/<span class="([^"]*)"/, '<li class="page-item \1"><span class="page-link"')
                      .gsub(/<a([^>]*)>/, '<li class="page-item"><a\1 class="page-link">')
                      .gsub(/<\/a>/, '</a></li>')
                      .gsub(/<\/span>/, '</span></li>')
                      .gsub(/class="page-item current"/, 'class="page-item active"')
                      .gsub(/class="page-item disabled"/, 'class="page-item disabled"')
                      .html_safe
      end
    end
  end

  # Pagination info helper with better formatting
  def pagination_info(collection)
    if collection.respond_to?(:total_entries)
      total = collection.total_entries
      per_page = collection.per_page
      current_page = collection.current_page
      
      start_item = (current_page - 1) * per_page + 1
      end_item = [current_page * per_page, total].min
      
      content_tag :div, class: "pagination-info" do
        content_tag :small, class: "text-muted" do
          raw("Showing <strong>#{start_item}#{end_item > start_item ? "-#{end_item}" : ""}</strong> of <strong>#{total}</strong> #{collection.model.name.downcase.pluralize}")
        end
      end
    end
  end
end
