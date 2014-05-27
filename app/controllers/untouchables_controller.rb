class UntouchablesController < AdminController
    
  def new
    @untouchable = Untouchable.new(client_id: params[:client_id])
    respond_to do |format|
      format.html { render_restfully_form }
      format.json { render :json => @untouchable }
      format.xml  { render :xml => @untouchable }
    end
  end
  
  def create
    @untouchable = Untouchable.new(params[:untouchable])
    respond_to do |format|
      if @untouchable.save
        format.html { redirect_to (params[:redirect] || user_url(@untouchable.client, anchor: :untouchables)) }
        format.json { render :json => @untouchable, :status => :created, :location => @untouchable }
      else
        format.html { render_restfully_form }
        format.json { render :json => @untouchable.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @untouchable = Untouchable.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @untouchable = Untouchable.find(params[:id])
    respond_to do |format|
      if @untouchable.update_attributes(params[:untouchable])
        format.html { redirect_to (params[:redirect] || user_url(@untouchable.client, anchor: :untouchables)) }
        format.json { head :no_content }
      else
        format.html { render_restfully_form }
        format.json { render :json => @untouchable.errors, :status => :unprocessable_entity }
      end
    end
  end
    

  def destroy
    @untouchable = Untouchable.find(params[:id])
    @untouchable.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || user_url(@untouchable.client, anchor: :untouchables)) }
      format.json { head :no_content }
    end
  end

end
