class Distributor < ActionMailer::Base

  def news(recipient, communication)
    @communication = communication
    @recipient = recipient
    @message_url = message_url(@communication.to_param, :host => "agrimail.fr")
    @unsubscribe_url = unsubscribe_url(@communication.client_id, recipient, :host => "agrimail.fr")
    attachments.inline[@communication.flyer.original_filename] = File.read(@communication.flyer.path(:web))
    mail(:to => recipient, :from => @communication.from, :subject => @communication.subject)
  end

end
