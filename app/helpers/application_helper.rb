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
    # # Alignment
    # html.gsub!(/^\ {4}\ *([^\n]+\w+[^\n]+)\ *\ {4}/, '<center>\1</center>')
    # html.gsub!(/\s*\<\/center\>\s*\<center\>\s*/, '<br/>')
    # html.gsub!('<center>', '<div style="text-align: center">')
    # html.gsub!(/\s*\<\/center\>/, '</div>')

    # # html.gsub!(/\ {4}\ *([^\n]+\w+[^\n]+)\ *\ {4}/, '<center>\1</center>')
    # html.gsub!(/^\ {4}\ *([^\n]+)/, '<right>\1</right>')
    # html.gsub!(/\<\/right\>\s*\<right\>/, '<br/>')
    # html.gsub!('<right>', '<div style="text-align: right">')
    # html.gsub!(/\s*\<\/right\>/, '</div>')


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
        "<#{t} class=\"a-#{align}\" style=\"text-align: #{align}\">#{data.strip}</#{t}>"
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


    # TABBOX
  def tabbox(id, options={})
    tb = Tabbox.new(id)
    yield tb
    return '' if tb.tabs.size.zero?
    tabs = ''
    taps = ''
    session[:tabbox] ||= {}
    for tab in tb.tabs
      session[:tabbox][tb.id] ||= tab[:name]
      active = (session[:tabbox][tb.id].to_s == tab[:name].to_s ? true : false)
      tabs << content_tag(:li, link_to(tab[:label], "#"+tab[:name].to_s, "data-toggle" => "tab"), (active ? {:class => :active} : {}))
      taps << content_tag(:div, capture(&tab[:block]).html_safe, tab[:options].merge(:id => tab[:name], :class => (active ? "active " : "") + "tab-pane"))
    end

    return content_tag(:div, :class => "tabbable", :id => tb.id, "data-tabbox" => url_for(:controller => :admin, :action => :toggle_tab, :id => tb.id)) do
      code  = content_tag(:ul, tabs.html_safe, :class => "nav nav-tabs")
      code << content_tag(:div, taps.html_safe, :class => "tab-content")
      code
    end
  end


  class Tabbox
    attr_accessor :tabs, :id

    def initialize(id = nil)
      @tabs = []
      @id = id.to_s
      @sequence = 0
    end

    # Register a tab with a block of code
    # The name of tab use I18n searching in :
    #   - labels.<tabbox_id>_tabbox.<tab_name>
    #   - labels.<tab_name>
    def tab(name, *args, &block)
      options = {}
      options = args.delete_at(-1) if args[-1].is_a?(Hash)
      label = args[0] || name.to_s.humanize
      raise ArgumentError.new("No given block") unless block_given?
      @tabs << {:name => name, :label => label, :options => options, :block => block}
      # , :index => (@sequence*1).to_s(36)
      @sequence += 1
    end

  end

  

end
