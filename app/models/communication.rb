# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: communications
#
#  id                 :integer          not null, primary key
#  client_id          :integer          not null
#  name               :string(255)
#  planned_on         :date
#  sender_label       :string(255)
#  sender_email       :string(255)
#  reply_to_email     :string(255)
#  test_email         :string(255)
#  message            :text
#  flyer_file_name    :string(255)
#  flyer_file_size    :integer
#  flyer_content_type :string(255)
#  flyer_updated_at   :datetime
#  flyer_fingerprint  :string(255)
#  distributed        :boolean          default(FALSE), not null
#  distributed_at     :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  lock_version       :integer          default(0), not null
#  subject            :string(255)
#  unsubscribe_label  :string(255)
#  unreadable_label   :string(255)
#  message_label      :string(255)
#  target_url         :string(255)
#  key                :string(255)
#  introduction       :text
#  conclusion         :text
#  newsletter_id      :integer
#

class Communication < ActiveRecord::Base
  attr_accessible :client_id, :name, :planned_on, :sender_email, :sender_label, :reply_to_email, :test_email, :message, :flyer, :unreadable_label, :unsubscribe_label, :message_label, :subject, :target_url, :newsletter_id, :introduction, :conclusion
  belongs_to :client, :class_name => "User", :counter_cache => true
  belongs_to :newsletter
  has_attached_file :flyer, {
    :styles => { :web => "640x2000>", :medium => "96x96#", :thumb => "48x48#" },
    :path => ":rails_root/public/system/:class/:attachment/:id_partition/:style/:filename",
    :url => "/system/:class/:attachment/:id_partition/:style/:filename"
  }
  has_many :articles, :dependent => :delete_all, :order => :position
  has_many :effects, :dependent => :delete_all
  has_many :touchables, :dependent => :delete_all, :order => :email
  has_many :testables, :class_name => "Touchable", :dependent => :delete_all, :order => :email, :conditions => {:test => true}

  delegate :global_style, :footer, :to => :newsletter
  
  after_initialize do
    self.unreadable_label ||= "Cliquez-ici si le message est illisible"
    self.unsubscribe_label ||= "Se désabonner"
    self.message_label ||= "Consulter le message en ligne"
  end

  before_validation do
    if self.key.blank?
      begin
        self.key = self.class.generate_key(43)
      end while self.class.find_by_key(self.key)
    end
  end

  def distribute_to(touchable)
    exception = []
    begin
      if self.newsletter
        Distributor.newsletter(touchable).deliver
      else
        Distributor.news(touchable).deliver
      end
    rescue Exception => e
      exception << e
    end
    return exception
  end

  def distribute(options = {})
    errors = []
    # self.touchables.where(options[:where]).where("email NOT IN (SELECT email FROM untouchables WHERE client_id=?)", self.client_id).find_each(:batch_size => 500) do |touchable|
    self.touchables.where(options[:where]).where("email NOT IN (SELECT email FROM untouchables)", self.client_id).find_each(:batch_size => 500) do |touchable|
      errors += self.distribute_to(touchable)
      touchable.update_attribute(:sent_at, Time.now)
    end
    # self.distributed_at = Time.now
    # self.distributed = true
    self.save
    return errors
  end

  def distributable?
    !self.distributed and self.touchables.count > 0
  end

  def from
    text = self.sender_email
    unless self.sender_label.blank?
      text = self.sender_label.gsub(/\</, '(').gsub(/\>/, ')')+" <" + text + ">"
    end
    return text
  end

  def self.generate_key(key_length = 20)
    letters = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W Y X Z) #  0 1 2 3 4 5 6 7 8 9)
    letters_length = letters.length
    key = ''
    key_length.times do 
      key << letters[(letters_length*rand).to_i]
    end
    return key
  end

  def title
    self.name
  end

  # Generate styles in CSS format
  def style
    style = self.global_style
    for rubric in self.newsletter.rubrics
      style << "\n.article.article-#{rubric.id} {\n" + rubric.article_style + "\n}\n"
    end
    if self.newsletter.header.file?
      header = self.newsletter.header
      geo = Paperclip::Geometry.from_file(header.path(:web))
      # style.gsub!('header-image', "url(\"#{header.url(:web)}\")")
      File.open(header.path(:web), "rb") do |file|
        style.gsub!('header-image', "url(data:image/jpg;base64,#{::Base64.encode64(file.read).to_s.gsub(/\s/, '')})")
      end
      style.gsub!('header-height', "#{geo.height}px")
      style.gsub!('header-width', "#{geo.width}px")
    end
    # raise style
    engine = Sass::Engine.new(style, :syntax => :scss)
    return engine.render
  end


  def self.beautify_for_html(text, options = {})
    html = text.dup
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
      title = link[1] || url
      "<a href=\"#{url}\">#{title}</a>"
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
      "<table><tbody><tr class=\"#{c}\">" + cells.join + "</tr></tbody></table>"
    end
    html.gsub!(/\<\/tbody\><\/table\>\ *\n?\ *\<table\>\<tbody\>/, '')

    return html
  end


  def to_html
    html = ""
    html << "<!DOCTYPE html>"
    html << "<html>"
    html << "<head>"
    html << "<meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />"
    html << "<meta charset=\"UTF-8\" />"
    html << "<title>" + self.title + "</title>"
    html << "</head>"
    html << "<body>"
    html << "<div id=\"page\">"

    # Header
    html << "<div id=\"header\">"
    html << "<h1>"+self.class.beautify_for_html(self.title)+"</h1>"
    html << "</div>" # /header    
    # Introduction
    unless self.introduction.blank?
      html << "<div id=\"introduction\">"
      html << self.class.beautify_for_html(self.introduction)
      html << "</div>" # /introduction
    end

    # Articles
    html << "<div id=\"articles\">"
    for article in self.articles
      html << "<div class=\"article article-#{article.rubric_id}\">"
      html << "<h2>" + self.class.beautify_for_html(article.title) + "</h2>"
      html << "<div class=\"content\">" + self.class.beautify_for_html(article.content) + "</div>"
      html << "</div>" # /article
    end
    html << "</div>" # /articles

    # Conclusion
    unless self.conclusion.blank?
      html << "<div id=\"conclusion\">"
      html << self.class.beautify_for_html(self.conclusion)
      html << "</div>" # /conclusion 
    end

    # Footer
    unless self.footer.blank?
      html << "<div id=\"footer\">"
      html << self.class.beautify_for_html(self.footer)
      html << "</div>" # /footer
    end

    html << "</div>" # /page
    html << "</body>"
    html << "</html>"
    
    # Generate CSS
    css = self.style

    # Merge HTML and CSS
    doc = Nokogiri::HTML(html) do |config|
      config.strict.nonet.noblanks
    end

    rules = css.split(/\s*\}\s*/).collect{|x| x.split(/\s*\{\s*/).collect{|x| x.strip.gsub(/\s+/, ' ')}}
    for selector, properties in rules
      doc.css(selector).each do |node|
        style = node["style"].to_s.split(/\s*\;\s+/).inject({}) do |hash, property|
          data = property.split(/\:/)
          hash[data[0].strip.downcase] = data[1..-1].join(":").strip
          hash 
        end
        new_style = properties.to_s.split(/\s*\;\s+/).inject({}) do |hash, property|
          data = property.split(/\:/)
          hash[data[0].strip.downcase] = data[1..-1].join(":").strip
          hash
        end
        node["style"] = style.merge(new_style).collect{|k,v| "#{k}: #{v}"}.join("; ")
      end
    end

    return doc.to_s
  end

  def to_pdf
  end

  def to_text
    
  end

end
