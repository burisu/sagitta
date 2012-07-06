class HomeController < ApplicationController

  def index
  end

  def unsubscribe
    client = User.find(params[:client_id])
    if client and params[:email]
      client.untouchables.create!(:email => params[:email])
    end
  end

  def show
    @communication = Communication.find(params[:id])    
  end

end
