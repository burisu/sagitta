class TouchablesController < AdminController
  
  # def new
  #   @touchable = Touchable.new
  #   communication = current_user.communications.find_by_id(params[:communication_id])
  #   if communication
  #     @touchable.communication = communication
  #     @touchable.newsletter = communication.newsletter
  #   end
  #   respond_to do |format|
  #     format.html { render_restfully_form(:multipart => true) }
  #     format.json { render :json => @touchable }
  #     format.xml  { render :xml => @touchable }
  #   end
  # end
  
  # def create
  #   @touchable = Touchable.new(params[:touchable])
  #   @touchable.communication = current_user.communications.find_by_id(@touchable.communication_id) unless current_user.administrator?
  #   respond_to do |format|
  #     if @touchable.save
  #       format.html { redirect_to (params[:redirect] || communication_url(@touchable.communication)) }
  #       format.json { render json => @touchable, :status => :created, :location => @touchable }
  #     else
  #       format.html { render_restfully_form(:multipart => true) }
  #       format.json { render :json => @touchable.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end
  
  def edit
    @touchable = Touchable.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form(:multipart => true) }
    end
  end
  
  def update
    @touchable = Touchable.find(params[:id])
    @touchable.communication = Communication.find_by_id(@touchable.communication_id)
    respond_to do |format|
      if @touchable.update_attributes(params[:touchable])
        format.html { redirect_to (params[:redirect] || communication_url(@touchable.communication)) }
        format.json { head :no_content }
      else
        format.html { render_restfully_form(:multipart => true) }
        format.json { render :json => @touchable.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @touchable = Touchable.find(params[:id])
    @touchable.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || communication_url(@touchable.communication)) }
      format.json { head :no_content }
    end
  end

end
