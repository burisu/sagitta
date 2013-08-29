class HomeController < ApplicationController

  def index
  end

  # Track unsubscriptions
  def unsubscribe
    @sending = Sending.find_by_key(params[:key])
    @sending.add(:unsubscribe)
    if @touchable = @sending.touchable
      @touchable.stroke!
    end
  end

  # Track message displaying
  def show
    unless @sending = Sending.find_by_key(params[:key])
      head :not_found
      return
    end
    @sending.add(:page_click)
    unless @communication = @sending.shipment.communication
      head :not_found
      return
    end
    if @communication.newsletter
      render :inline => @communication.to_html
    else
      render :action => :show, :layout => false
    end
  end

  # Track click on message
  def target
    unless @sending = Sending.find_by_key(params[:key])
      head :not_found
      return
    end
    @sending.add(:target_click)
    unless @communication = @sending.shipment.communication
      head :not_found
      return
    end
    redirect_to @communication.target_url
  end
  
  # Track e-mail openings
  def opening
    unless @sending = Sending.find_by_key(params[:key])
      head :not_found
      return
    end
    @sending.add(:opening)
    send_file(Rails.root.join("lib", "tracker", "opening-v2.png"))
  end

end
