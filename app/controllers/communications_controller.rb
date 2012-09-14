class CommunicationsController < AdminController
  
  list :effects do |t|
    t.column :nature
  end

  list :touchables, :conditions => ["communication_id = ? ", ['session[:communication_id]']] do |t|
    t.column :email
    t.column :fax
    t.column :test
    t.action :edit
    t.action :destroy
  end

  def show
    @communication = Communication.find(params[:id])
    @communication.save if @communication.key.blank?
    respond_to do |format|
      format.html { session[:communication_id] = @communication.id}
      format.pdf  { send_data @communication.to_pdf }
      format.json { render :json => @communication }
      format.xml  { render :xml => @communication }
    end
    
  end
  
  def new
    @communication = Communication.new(:client_id => params[:client_id])
    @communication.newsletter = (current_user.administrator ? Newsletter : current_user.newsletters).find_by_id(params[:newsletter_id])
    if @communication.newsletter
      @communication.introduction = @communication.newsletter.introduction
      @communication.conclusion   = @communication.newsletter.conclusion
      if previous = @communication.client.communications.order(:created_at).last
        for attr in [:name, :subject, :title, :sender_label, :sender_email, :reply_to_email, :target_url]
          @communication.send("#{attr}=", previous.send(attr))
        end
        @communication.introduction = previous.introduction if @communication.introduction.blank?
        @communication.conclusion   = previous.conclusion if @communication.conclusion.blank?
        @communication.subject.succ! if @communication.subject.match(/\d+$/)
        @communication.title.succ! if @communication.title.match(/\d+$/)
        @communication.name.succ! if @communication.name.match(/\d+$/)
      end
    end
    respond_to do |format|
      format.html { render_restfully_form(:multipart => true) }
      format.json { render :json => @communication }
      format.xml  { render :xml => @communication }
    end
  end
  
  def create
    @communication = Communication.new(params[:communication])
    @communication.client = current_user unless current_user.administrator?
    @communication.newsletter = current_user.newsletters.find_by_id(@communication.newsletter_id)
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
    @communication.client = current_user unless current_user.administrator?
    @communication.newsletter = current_user.newsletters.find_by_id(@communication.newsletter_id)
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
      clist = source.to_s.split(/\s*\n+\s*/).compact.collect{|x| x.to_s.mb_chars.downcase}.uniq
      for line in clist
        infos = line.split(/\s*\,\s*/)
        @communication.touchables.create(:email => infos[0], :fax => infos[1], :test => (params[:test].to_i == 1))
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
    settings = {}
    if params[:mode] == "real"
      settings[:where] = "TRUE"      
    elsif params[:mode] == "unsent"
      settings[:where] = "sent_at IS NULL"
    else
      settings[:where] = "test"
    end
    unless params[:only].blank?
      settings[:only] = params[:only].to_sym
    end
    @errors = @communication.distribute(settings)
  end

end
