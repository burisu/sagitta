class Distributor < ActionMailer::Base

  def news(touchable, options = {})
    @touchable = touchable
    @communication = @touchable.communication
    @message_url = message_url(@communication.key, :host => "agrimail.fr")
    @unsubscribe_url = unsubscribe_url(@touchable.key, :host => "agrimail.fr")
    attachments.inline[@communication.flyer.original_filename] = File.read(@communication.flyer.path(:web))
    settings = {:to => @touchable.email, :from => @communication.from, :subject => @communication.subject}
    settings[:reply_to] = @communication.reply_to_email unless @communication.reply_to_email.blank?
    mail(settings)
  end

end
