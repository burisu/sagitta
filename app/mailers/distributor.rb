class Distributor < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  # NOTE: Letter_opener does not work with attachments...

  def communication(touchable, options = {})
    @touchable = touchable
    @communication = @touchable.communication
    @message_url = message_url(@communication.key, :host => "agrimail.fr")
    @unsubscribe_url = unsubscribe_url(@touchable.key, :host => "agrimail.fr")
    if @communication.newsletter
      if @communication.with_pdf
        attachments[@communication.interpolate(@communication.subject).parameterize+".pdf"] = @communication.to_pdf
      end
      @articles = {}
      for article in @communication.articles
        if article.logo.file?
          path = article.logo.path(:web)
          @articles[article.id] = File.basename(path)
          attachments.inline[@articles[article.id]] = File.read(path)
        end
      end
      for piece in @communication.pieces
        attachments[piece.name.parameterize+".pdf"] = File.read(piece.document.path(:original))
      end
      if @communication.header.file?
        attachments.inline['header-image.png'] = File.read(@communication.header.path(:web))
      end
    else
      if @communication.flyer.file?
        attachments.inline[@communication.flyer.original_filename] = File.read(@communication.flyer.path(:web))
      end
    end
    settings = {:to => @touchable.email, :from => @communication.from, :subject => @communication.interpolate(@communication.subject)}
    settings[:reply_to] = @communication.reply_to_email unless @communication.reply_to_email.blank?
    mail(settings) do |format|
      format.text("Content-type" => "text/plain; charset=utf8")
      format.html("Content-type" => "text/html; charset=utf8")
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
    settings = {:to => "fax@ecofax.fr", :from => "fax-reply@agrimail.fr", :subject => @communication.newsletter.ecofax_number}
    settings[:reply_to] = @communication.reply_to_email unless @communication.reply_to_email.blank?
    mail(settings)
  end



end
