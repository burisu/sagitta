class HomeController < ApplicationController

  def index
  end

  def unsubscribe
    client = User.find(params[:client_id])
    if client and params[:email]
      email = Base64.urlsafe_decode64(params[:email])
      client.untouchables.create!(:email => email)
    end
  end

  def show
    @communication = Communication.find(params[:id])    
    render :action => :show, :layout => false
  end

end
