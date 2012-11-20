# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: communications
#
#  id                    :integer          not null, primary key
#  client_id             :integer          not null
#  name                  :string(255)
#  planned_on            :date
#  sender_label          :string(255)
#  sender_email          :string(255)
#  reply_to_email        :string(255)
#  test_email            :string(255)
#  message               :text
#  flyer_file_name       :string(255)
#  flyer_file_size       :integer
#  flyer_content_type    :string(255)
#  flyer_updated_at      :datetime
#  flyer_fingerprint     :string(255)
#  distributed           :boolean          default(FALSE), not null
#  distributed_at        :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  lock_version          :integer          default(0), not null
#  subject               :string(255)
#  unsubscribe_label     :string(255)
#  unreadable_label      :string(255)
#  message_label         :string(255)
#  target_url            :string(255)
#  key                   :string(255)
#  introduction          :text
#  conclusion            :text
#  newsletter_id         :integer
#  title                 :string(255)
#  with_pdf              :boolean          default(FALSE), not null
#  nature                :string(255)
#  document_file_name    :string(255)
#  document_content_type :string(255)
#  document_file_size    :integer
#  document_updated_at   :datetime
#

class Communication < ActiveRecord::Base
  include Prawn::Measurements

  @@natures = ["flyer", "newsletter", "document"]
  attr_accessible :client_id, :name, :planned_on, :sender_email, :sender_label, :reply_to_email, :test_email, :message, :flyer, :unreadable_label, :unsubscribe_label, :message_label, :subject, :target_url, :newsletter_id, :introduction, :conclusion, :title, :with_pdf, :document, :nature
  belongs_to :client, :class_name => "User", :counter_cache => true
  belongs_to :newsletter
  has_many :articles, :dependent => :delete_all, :order => :position
  has_many :effects, :dependent => :delete_all
  has_many :pieces, :dependent => :destroy
  has_many :alone_pieces, :class_name => "Piece", :conditions => "article_id IS NULL"
  has_many :touchables, :dependent => :delete_all, :order => "canal, coordinate"
  has_many :testables, :class_name => "Touchable", :dependent => :delete_all, :order => :email, :conditions => {:test => true}
  has_many :shipments, :order => "started_at DESC"
  has_many :active_shipments, :conditions => {:state => "sending"}, :class_name => "Shipment", :order => "started_at DESC"
  has_attached_file :flyer, {
    :styles => { :web => "640x2000>", :medium => "96x96#", :thumb => "48x48#" },
    :path => ":rails_root/public/system/:class/:attachment/:id_partition/:style/:filename",
    :url => "/system/:class/:attachment/:id_partition/:style/:filename"
  }
  has_attached_file :document, {
    :path => ":rails_root/private/:class/:attachment/:id_partition/:style/:filename",
    :url => "/system/:class/:attachment/:id_partition/:style/:filename"
  }

  validates_presence_of :nature
  validates_presence_of :newsletter, :if => Proc.new{|c| c.newsletter? }
  validates_attachment_presence :document, :if => Proc.new{|c| c.document? }
  validates_attachment_content_type :document, :content_type => ["application/pdf", "application/x-pdf"], :if => Proc.new{|c| c.document? }
  validates_attachment_presence :flyer, :if => Proc.new{|c| c.flyer? }
  validates_inclusion_of :nature, :in => @@natures

  delegate :global_style, :print_style, :header, :footer, :to => :newsletter


  after_initialize do
    self.unreadable_label ||= "Cliquez-ici si le message est illisible"
    self.unsubscribe_label ||= "Se désabonner"
    self.message_label ||= "Consulter le message en ligne"
  end

  before_validation do
    if self.document?
      if self.document.queued_for_write[:original]
        input = self.document.queued_for_write[:original].path
        output = Rails.root.join("tmp", "doc-out-"+rand(10000000).to_s(36)+".jpg")
        system("convert -antialias -density 200x200 \"#{input}[0]\" #{output}")
        File.open(output, "rb") do |f|
          self.flyer = f
        end
      end
    end

    if self.key.blank?
      begin
        self.key = self.class.generate_key(43)
      end while self.class.find_by_key(self.key)
    end
  end

  def send_shipment(options = {})
    filter = {}
    description = "Envoi"
    if options[:mode] == :real
      description << " réel"
    else
      description << " test"
      filter[:test] = true
    end
    if options[:only]
      description << " (#{options[:only].to_s.humanize} seulement)"
      filter[:canal] = options[:only]
    end
    shipment = self.shipments.create!(:description => description)
    self.touchables.where("search_key NOT IN (SELECT search_key FROM untouchables)").where(filter).find_each do |touchable|
      shipment.sendings.create!(:touchable => touchable)
    end
    shipment.total = shipment.sendings.count
    shipment.save
    shipment.distribute
    return shipment
  end

  # def distribute_to(touchable, mode = :all)
  #   mode ||= :all
  #   mode = [:email, :fax] if mode == :all
  #   mode = [mode] unless mode.is_a? Array
  #   exception = nil
  #   if mode.include?(:email) and !touchable.email.blank?
  #     begin
  #       Distributor.communication(touchable).deliver
  #     rescue Exception => e
  #       exception = e
  #     end
  #   end
  #   if mode.include?(:fax) and !touchable.fax.blank? and touchable.email.blank?
  #     begin
  #       Distributor.fax_request(touchable).deliver
  #     rescue Exception => e
  #       exception = e
  #     end
  #   end
  #   return exception
  # end

  # def distribute(options = {})
  #   shipment = self.shipments.create
  #   shipment.distribute(options)
  #   # report = {}
  #   # report[:count] = 0
  #   # report[:errors] = {}
  #   # # self.touchables.where(options[:where]).where("email NOT IN (SELECT email FROM untouchables)", self.client_id).find_each(:batch_size => 500) do |touchable|
  #   # #   report[:count] += 1
  #   # #   if x = self.distribute_to(touchable, options[:only])
  #   # #     report[:errors][touchable.id] = {:error => x, :touchable => touchable}
  #   # #   end
  #   # #   touchable.update_attribute(:sent_at, Time.now)
  #   # # end
  #   # # self.save
  #   # return report
  # end

  def distributable?
    !self.distributed and self.touchables.count > 0
  end

  def full_title
    t = self.title
    t += (" ‒ " + self.planned_on.l) if self.newsletter.name.match(/\#/)
    return t 
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

  # Generate styles in CSS format
  def style(media = :screen, options = {})
    style = ""
    # Global style
    if self.newsletter
      style << self.global_style
      # Rubric styles
      for rubric in self.newsletter.rubrics
        unless rubric.article_style.blank?
          style << "\n.article.article-#{rubric.id} {\n" + rubric.article_style + "\n}\n"
        end
      end
      if media == :print
        style << self.print_style.to_s
        for rubric in self.newsletter.rubrics
          unless rubric.article_print_style.blank?
            style << "\n.article.article-#{rubric.id} {\n" + rubric.article_print_style + "\n}\n"
          end
        end
      end

      # Interpolations
      if self.newsletter.header.file?
        header = self.newsletter.header
        geo = Paperclip::Geometry.from_file(header.path(:web))
        # style.gsub!('header-image', "url(\"#{header.url(:web)}\")")
        File.open(header.path(:web), "rb") do |file|
        style.gsub!('header-image', "url(data:image/jpg;base64,#{::Base64.encode64(file.read).to_s.gsub(/\s/, '')})")
        end
        style.gsub!('header-path', header.path(:web))
        style.gsub!('header-url', options[:header_url] || header.url(:web))
        style.gsub!('header-height', "#{geo.height}px")
        style.gsub!('header-width', "#{geo.width}px")
      end
    else
      style << "a { display: block; text-align:center; margin: 0 auto; } "
      style << "a img { max-height: 260mm; width: auto; margin: 0 auto; } "
    end
    # raise style
    engine = Sass::Engine.new(style, :syntax => :scss, :style => :compressed)
    return engine.render()
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

    return html
  end




  def to_html(media = :screen, options = {})
    html = ""
    html << "<!DOCTYPE html>"
    html << "<html>"
    html << "<head>"
    html << "<meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />"
    html << "<meta charset=\"UTF-8\" />"
    html << "<title>" + self.subject + "</title>"
    html << "<style>" + self.style(media) + "</style>"
    # '@import url("http://fonts.googleapis.com/css?family=Open+Sans:400,400italic,700,700italic");'

    html << "</head>"
    html << "<body>"

    html << "<div id=\"page\">"

    if self.newsletter
      # Header
      #html << "<div id=\"header\">"
      if media == :print and self.header.file?
        html << "<img id=\"header\" src=\"" + self.header.path(:web) + "\">"
      end
      html << "<h1>"+self.class.beautify_for_html(self.title)+"</h1>"
      #html << "</div>" # /header    
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
        html << "<img src=\"" + article.logo.path(:inch) + "\">" if article.logo.exists?
        html << "<h2>" + self.class.beautify_for_html(article.title) + "</h2>"
        html << "<div class=\"content\">" + self.class.beautify_for_html(article.content) + "</div>"
        unless article.readmore_url.blank?
          html << "<div class=\"readmore\">" + article.readmore_label+" : <a href=\""+URI.escape(article.readmore_url)+"\">" + URI.escape(article.readmore_url) + "</a></div>"
        end
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
    else
      html << "<a href='#{self.target_url}'>"
      if media == :print and self.flyer.file?
        html << "<img src='#{self.flyer.path(:original)}'/>"
      end
      html << "</a>"
    end

    if options[:mail].is_a?(Sending)
      html << "<div style=\"position: absolute; left: 9.5cm; width: 8cm; top: 3.5cm; background: rgba(255, 255, 255, 0.6); padding: 5mm; font-size: 4mm; line-height: 5mm; font-family: monospace; border-radius: 5mm; border: 0.2mm solid #777777;\">"
      html << options[:mail].coordinate.split(";").join("<br/>")
      html << "</div>"
    end


    html << "</div>" # /page

    html << "</body>"
    html << "</html>"
    return self.interpolate(html)
    
    # # Generate CSS
    # css = self.style

    # # Merge HTML and CSS
    # doc = Nokogiri::HTML(html) do |config|
    #   config.strict.nonet.noblanks
    # end

    # rules = css.split(/\s*\}\s*/).collect{|x| x.split(/\s*\{\s*/).collect{|x| x.strip.gsub(/\s+/, ' ')}}
    # for selector, properties in rules
    #   doc.css(selector).each do |node|
    #     style = node["style"].to_s.split(/\s*\;\s+/).inject({}) do |hash, property|
    #       data = property.split(/\:/)
    #       hash[data[0].strip.downcase] = data[1..-1].join(":").strip
    #       hash 
    #     end
    #     new_style = properties.to_s.split(/\s*\;\s+/).inject({}) do |hash, property|
    #       data = property.split(/\:/)
    #       hash[data[0].strip.downcase] = data[1..-1].join(":").strip
    #       hash
    #     end
    #     node["style"] = style.merge(new_style).collect{|k,v| "#{k}: #{v}"}.join("; ")
    #   end
    # end
    # return doc.to_s
  end

  def to_pdf(options = {})
    data = nil
    if self.document?
      File.open(self.document.path(:original), "rb") do |f|
        data = f.read
      end
    else
      data = WickedPdf.new.pdf_from_string(self.to_html(:print, options))
    end
    return data
  end

  def mail_to(sending, options = {})
    file = options[:output] || Rails.root.join("tmp", "sending-mail-#{sending.id}.pdf")
    if self.document?
      Prawn::Document.generate(file, :template => self.document.path(:original), :margin => [0, 0, 0, 0]) do |pdf|
        address = sending.coordinate.split(";").delete_if{|x| x.blank?}
        pdf.font_families.update("Inconsolata" => { :normal => Rails.root.join("lib", "fonts", "Inconsolata-Regular.ttf").to_s})
        font_size = 4
        margin, at, dims = 2, [108, 250], [82, 30]
        pdf.font "Inconsolata", :size => mm2pt(font_size)
        pdf.font_size
        pdf.fill_color "FFFFFF"
        pdf.fill do
          pdf.rounded_rectangle [mm2pt(at[0]-margin), mm2pt(at[1]+margin)], mm2pt(dims[0]+2*margin), mm2pt(dims[1]+2*margin), mm2pt(margin)
        end
        pdf.fill_color "000000"
        pdf.bounding_box([mm2pt(at[0]), mm2pt(at[1])], :width => mm2pt(dims[0]), :height => mm2pt(dims[1])) do
          pdf.text address.join("\r\n"), :valign => :center
        end
        # pdf.text_box address.join("\r\n"), :at => [mm2pt(at[0]), mm2pt(at[1])], :width => mm2pt(dims[0]), :height => mm2pt(dims[1]), :align => :left, :valign => :center
      end
    else
      File.open(file, "wb") do |f|
        f.write self.communication.to_pdf(:mail => sending)
      end
    end
    return file
  end


  def interpolate(text)
    out = text.to_s.dup
    out.gsub!('[NEWSLETTER]', self.newsletter.name) if self.newsletter
    out.gsub!('[NAME]', self.name)
    out.gsub!('[DATE]', self.planned_on.l)    
    return out
  end

  def duplicate!
    c = self.dup
    c.id = nil
    c.name = "Copie de #{c.name}"
    c.save!
    return c
  end


  def newsletter?
    (self.nature == "newsletter" ? true : false)
  end

  def flyer?
    (self.nature == "flyer" ? true : false)
  end

  def document?
    (self.nature == "document" ? true : false)
  end

end
