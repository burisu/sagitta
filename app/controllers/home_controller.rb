class HomeController < ApplicationController

  def index
  end

  def unsubscribe
    @touchable = Touchable.find_by_key(params[:key])
    @touchable.stroke!
  end

  def show
    @communication = Communication.find_by_key(params[:key])
    render :action => :show, :layout => false
  end

end
