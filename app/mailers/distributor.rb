class Distributor < ActionMailer::Base

  def news(recipient, communication)
    @communication = communication
    attachments.inline[@communication.flyer.original_filename] = File.read(@communication.flyer.path(:web))
    mail(:to => recipient)
  end

end
