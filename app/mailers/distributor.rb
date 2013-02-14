# -*- coding: utf-8 -*-
class Distributor < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  # NOTE: Letter_opener does not work with attachments...

  def communication(sending, options = {})
    host = (Rails.env.development? ? "localhost:3000" : "agrimail.fr")
    @sending       = sending
    @touchable     = @sending.touchable
    @communication = @touchable.communication
    @message_url     = message_url(@sending.key,     :host => host)
    @target_url      = target_url(@sending.key,      :host => host)
    @opening_url     = opening_url(@sending.key,     :host => host)
    @unsubscribe_url = unsubscribe_url(@sending.key, :host => host)
    if @communication.newsletter
      if @communication.with_pdf
        attachments[@communication.interpolate(@communication.subject).parameterize+".pdf"] = @communication.to_pdf
      end
      @articles = {}
      for article in @communication.articles
        if article.logo.file?
          @articles[article.id] = unique_image_name
          attachments.inline[@articles[article.id]] = File.read(article.logo.path(:web))
        end
      end
      if @communication.header.file?
        @header = unique_image_name
        attachments.inline[@header] = File.read(@communication.header.path(:web))
      end
    else
      headers['List-Unsubscribe'] = "<"+@unsubscribe_url.strip+">"
      if @communication.flyer.file?
        attachments.inline[@communication.flyer.original_filename] = File.read(@communication.flyer.path(:web))
      end
    end
    for piece in @communication.pieces
      attachments[piece.name.parameterize+".pdf"] = File.read(piece.document.path(:original))
    end
    if @communication.document?
      attachments[@communication.document.original_filename] = File.read(@communication.document.path(:original))
    end
    settings = {:to => @touchable.coordinate, :from => @communication.from, :subject => normalize(@communication.interpolate(@communication.subject))}
    settings[:reply_to] = @communication.reply_to_email unless @communication.reply_to_email.blank?
    settings[:charset] = "ISO-8859-15"
    mail(settings) do |format|
      unless @communication.document?
        format.text  { normalize(render("communication")) }
      end
      format.html { normalize(render("communication")) }
    end
  end


  def fax_request(touchable, options = {})
    raise ArgumentError.new("Touchable is not valid: No fax") if touchable.fax.blank?
    @communication = touchable.communication
    attachments[@communication.title.parameterize+".pdf"] = @communication.to_pdf
    attachments["numbers.txt"] = touchable.fax
    for piece in @communication.pieces
      attachments[piece.name.parameterize+".pdf"] = File.read(piece.document.path(:original))
    end
    settings = {:to => "fax@ecofax.fr", :from => "fax-reply@agrimail.fr", :subject => @communication.ecofax_number}
    settings[:reply_to] = @communication.reply_to_email unless @communication.reply_to_email.blank?
    mail(settings)
  end

  def fax_shipment_request(shipment, options = {})
    @communication = shipment.communication
    attachments[@communication.title.parameterize+".pdf"] = @communication.to_pdf
    attachments["numbers.txt"] = shipment.sendings.where(:canal => "fax").collect{|s| s.coordinate}.join("\n")
    for piece in @communication.pieces
      attachments[piece.name.parameterize+".pdf"] = File.read(piece.document.path(:original))
    end
    settings = {:to => "fax@ecofax.fr", :from => "fax-reply@agrimail.fr", :subject => @communication.ecofax_number}
    settings[:reply_to] = @communication.reply_to_email unless @communication.reply_to_email.blank?
    mail(settings)
  end


  private

  def unique_image_name(extension = :jpg)
    return rand.to_s[2..-1].to_i.to_s(36)+Time.now.to_i.to_s(36)+"."+extension.to_s
  end


  def normalize(string)
    string.gsub!("–", "-")
    string.gsub!("—", "-")
    string.gsub!("‒", "-")
    string.gsub!("’", "'")
    string.encode!("ISO-8859-15", :undef => :replace)
    return string
  end

end
