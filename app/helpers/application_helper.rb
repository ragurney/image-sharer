module ApplicationHelper
  include Loginable

  def nav_item(body, url, html_options = {})
    active = 'active' if current_page?(url)
    classes = [active, 'nav-item']
    content_tag :li, class: classes do
      link_to body, url, html_options
    end
  end
end
