module ApplicationHelper

  def show_flashes
    messages = ''.html_safe 
    flash.collect { |k,v| 
      messages << content_tag(:div, v.html_safe, :class => "flash #{k}" )
    }
    content_tag(:div, messages, :id => 'notifications')
  end

end
