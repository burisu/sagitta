class Distributor < ActionMailer::Base
  add_template_helper(ApplicationHelper)

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


  def newsletter(touchable, options = {})
    @touchable = touchable
    @communication = @touchable.communication
    # @communication.from ||
    settings = {:to => @touchable.email, :from =>  'nobody@nowhere.tld', :subject => @communication.subject}
    settings[:reply_to] = @communication.reply_to_email unless @communication.reply_to_email.blank?
    headers["Content-type"] = "text/html; charset=utf-8"
    mail(settings)
  end



end
