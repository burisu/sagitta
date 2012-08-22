class HomeController < ApplicationController

  def index
  end

  def unsubscribe
    @touchable = Touchable.find_by_key(params[:key])
    @touchable.stroke!
  end

  def show
    unless @communication = Communication.find_by_key(params[:key])
      head :not_found
      return
    end
    render :action => :show, :layout => false
  end

end
