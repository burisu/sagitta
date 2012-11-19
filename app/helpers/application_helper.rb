# -*- coding: utf-8 -*-
module ApplicationHelper

  def interpolate(text)
    x = self.instance_variable_get("@communication")
    return x.interpolate(text)
  end


  # Convert enhanced text to html
  def beautify(text)

    html = interpolate(text)

    for character, escape in {"&" => "&amp;", "<" => "&lt;", ">" => "&gt;", "'" => "’"}
      html.gsub!(character, escape)
    end
    html.gsub!(/^\ \ [\*\-]\ +(.*)\ *$/, '<ul><li>\1</li></ul>')
    html.gsub!(/\<\/ul\>\ *\n?\ *\<ul\>/, '')
    # Stars
    html.gsub!(/(^|[^\*])\*([^\*]|$)/, '\1&lowast;\2')
    # Emphase
    html.gsub!(/([^\:])\/\/([^\s][^\/]+)\/\//, '\1<em>\2</em>')
    # Strong
    html.gsub!(/\*\*([^\s\*][^\*]*[^\s\*])\*\*/, '<strong>\1</strong>')
    # URL
    html.gsub!(/\[\[[^\|\]]+(\|[^\]]+)?\]\]/) do |link|
      link = link[2..-3].strip.split("|")
      url = link[0].strip
      url = "http://"+url unless url.match(/^\w+\:\/\//)
      label = link[1] || url
      "<a href=\"#{url}\">#{label}</a>"
    end
    # Tables
    classes = [:odd, :even]
    c = nil
    html.gsub!(/^\ *\|(.*)\|\ *\r?\n/) do |line|
      cells = line.strip[1..-1].split(/\|/).collect do |data|
        t, align = "td", "left"
        if data[0..0] == "#"
          t = "th" 
          data = data[1..-1]
        end
        if data[0..1] == "  "
          if data.size > 4 and data[-2..-1] == "  "
            align = "center"
          else
            align = "right"
          end
        end
        "<#{t} class=\"a-#{align}\">#{data.strip}</#{t}>"
      end
      c = classes[classes.index(c) ? (classes.index(c) + 1)  : 0] || classes[0]
      "<table class=\"cnt\"><tbody><tr class=\"#{c}\">" + cells.join + "</tr></tbody></table>"
    end
    html.gsub!(/\<\/tbody\><\/table\>\ *\n?\ *\<table class\=\"cnt\"\>\<tbody\>/, '')
    html.gsub!(/\r\n/, '<br/>')
    html.gsub!(/\n/, '<br/>')

    return html.html_safe
  end

  # Convert enhanced text to simple text
  def textize(text)
  end

  def textify(etext, options = {})
    coder = HTMLEntities.new
    text = coder.decode(interpolate(etext));
    # List
    text.gsub!(/^\ \ [\*\-]\ +(.*)\ *$/, '  ‒ \1')
    # Emphase
    text.gsub!(/([^\:])\/\/([^\s][^\/]+)\/\//, '\1  \2  ')
    # Strong
    text.gsub!(/\*\*([^\s\*][^\*]*[^\s\*])\*\*/, '  \1  ')
    # URL
    text.gsub!(/\[\[[^\|\]]+(\|[^\]]+)?\]\]/) do |link|
      link = link[2..-3].strip.split("|")
      url = link[0].strip
      url = "http://"+url unless url.match(/^\w+\:\/\//)
      label = link[1]
      (label.blank? ? url : "#{label} (#{url})")
    end
    
    text.gsub!(/([^\|\s|]|^)\s+([^\|\s]|$)/, '\1 \2')

    text = word_wrap(text, :line_width => 100)

    maxl = text.split(/\n/).collect{|l| l.strip.size}.max || 100
    if options[:mode] == :h1
      text = "=" * maxl+"\n"+text.strip+"\n"+"=" * maxl
    elsif options[:mode] == :h2
      text = text.strip+"\n"+"-"*maxl
    end
    return text.html_safe
  end


  def page_title(name)
    content_for(:page_title, name)
  end

  def desc(&block)
    content_for(:page_description, capture(&block))
  end


  def toolbar(&block)
    return content_tag(:div, content_tag(:div, capture(&block), :class => "btn-group"), :class => "btn-toolbar")
  end

  INTERPOLATE = {
    "destroy" => "remove",
    "delete" => "remove"
  }

  def tool(*args)
    args[2] ||= {}
    args[2][:class] ||= ""
    args[2][:class] << "btn"
    if args[2][:icon]
      icon = args[2].delete(:icon).to_s
      icon.gsub!(/\_/, '-')
      icon = INTERPOLATE[icon] || icon
      args[2][:title] = args[0]
      args[0] = content_tag(:i, nil, :class => "icon-"+icon) #  + h(args[0])
    end
    link_to(*args)
  end
  

end
