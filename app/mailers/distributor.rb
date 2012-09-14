class Distributor < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  # def news(touchable, options = {})
  #   @touchable = touchable
  #   @communication = @touchable.communication
  #   @message_url = message_url(@communication.key, :host => "agrimail.fr")
  #   @unsubscribe_url = unsubscribe_url(@touchable.key, :host => "agrimail.fr")
  #   attachments.inline[@communication.flyer.original_filename] = File.read(@communication.flyer.path(:web))
  #   settings = {:to => @touchable.email, :from => @communication.from, :subject => @communication.subject}
  #   settings[:reply_to] = @communication.reply_to_email unless @communication.reply_to_email.blank?
  #   mail(settings)
  # end


  # def newsletter(touchable, options = {})
  #   @touchable = touchable
  #   @communication = @touchable.communication
  #   @message_url = message_url(@communication.key, :host => "agrimail.fr")
  #   @unsubscribe_url = unsubscribe_url(@touchable.key, :host => "agrimail.fr")
  #   if @communication.flyer.file?
  #     attachments.inline[@communication.flyer.original_filename] = File.read(@communication.flyer.path(:web))
  #   end
  #   if @communication.header.file?
  #     attachments.inline['header-image.png'] = File.read(@communication.header.path(:web))
  #   end
  #   settings = {:to => @touchable.email, :from => @communication.from, :subject => @communication.subject}
  #   settings[:reply_to] = @communication.reply_to_email unless @communication.reply_to_email.blank?
  #   mail(settings)
  # end

  def communication(touchable, options = {})
    @touchable = touchable
    @communication = @touchable.communication
    @message_url = message_url(@communication.key, :host => "agrimail.fr")
    @unsubscribe_url = unsubscribe_url(@touchable.key, :host => "agrimail.fr")
    if @communication.flyer.file?
      attachments.inline[@communication.flyer.original_filename] = File.read(@communication.flyer.path(:web))
    end
    if @communication.header.file?
      attachments.inline['header-image.png'] = File.read(@communication.header.path(:web))
    end
    settings = {:to => @touchable.email, :from => @communication.from, :subject => @communication.subject}
    settings[:reply_to] = @communication.reply_to_email unless @communication.reply_to_email.blank?
    mail(settings)
  end


  def fax_request(touchable, options = {})
    raise ArgumentError.new("Touchable is not valid: No fax") if touchable.fax.blank?
    @communication = touchable.communication
    attachments[@communication.title.parameterize+".pdf"] = @communication.to_pdf
    attachments["numbers.txt"] = touchable.fax
    settings = {:to => "fax@ecofax.fr", :from => @communication.from, :subject => @communication.newsletter.ecofax_number}
    settings[:reply_to] = @communication.reply_to_email unless @communication.reply_to_email.blank?
    mail(settings)
  end



end
