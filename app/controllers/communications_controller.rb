class CommunicationsController < AdminController
  
  list :effects do |t|
    t.column :nature
  end

  list :touchables, :conditions => ["communication_id = ? ", ['session[:communication_id]']] do |t|
    t.column :email
    t.column :test
    t.column :key
    t.action :edit
    t.action :destroy
  end

  def show
    @communication = Communication.find(params[:id])
    @communication.save if @communication.key.blank?
    session[:communication_id] = @communication.id
  end
  
  def new
    @communication = Communication.new(:client_id => params[:client_id])
    respond_to do |format|
      format.html { render_restfully_form(:multipart => true) }
      format.json { render :json => @communication }
      format.xml  { render :xml => @communication }
    end
  end
  
  def create
    @communication = Communication.new(params[:communication])
    respond_to do |format|
      if @communication.save
        format.html { redirect_to (params[:redirect] || communication_url(@communication)) }
        format.json { render json => @communication, :status => :created, :location => @communication }
      else
        format.html { render_restfully_form(:multipart => true) }
        format.json { render :json => @communication.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @communication = Communication.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form(:multipart => true) }
    end
  end
  
  def update
    @communication = Communication.find(params[:id])
    respond_to do |format|
      if @communication.update_attributes(params[:communication])
        format.html { redirect_to (params[:redirect] || communication_url(@communication)) }
        format.json { head :no_content }
      else
        format.html { render_restfully_form(:multipart => true) }
        format.json { render :json => @communication.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @communication = Communication.find(params[:id])
    @communication.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || user_url(@communication.client)) }
      format.json { head :no_content }
    end
  end

  def populate
    @communication = Communication.find(params[:id])
    if request.post?
      source = ""
      if params[:touchables_file]
        name = params[:touchables_file].original_filename
        path = Rails.root.join("tmp", "codes-import.#{name}.#{rand.to_s[2..16].to_i.to_s(36)}.csv")
        File.open(path, "wb") { |f| f.write(params[:touchables_file].read) }
        File.open(path, "rb") { |f| source = f.read }
        File.delete(path)
      elsif params[:touchables_list]
        source = params[:touchables_list].to_s
      else
        raise Exception.new("Unvalid import method")
      end
      clist = source.to_s.split(/\s+/).compact.collect{|x| x.to_s.mb_chars.downcase}.uniq
      for email in clist
        @communication.touchables.create(:email => email, :test => (params[:test].to_i == 1))
      end
      redirect_to communication_url(@communication)
    end
  end

  def clear
    @communication = Communication.find(params[:id])
    @communication.touchables.clear
    redirect_to communication_url(@communication)
  end

  def distribute
    @communication = Communication.find(params[:id])
    @errors = if params[:mode] == "real"
                @communication.distribute
              elsif params[:mode] == "unsent"
                @communication.distribute(:where => "sent_at IS NULL")
              else
                @communication.distribute(:where => "test")
              end
  end

end
