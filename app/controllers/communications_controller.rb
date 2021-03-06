class CommunicationsController < AdminController
  
  list :effects do |t|
    t.column :nature
  end

  list :touchables, :conditions => ["communication_id = ? ", ['session[:communication_id]']] do |t|
    t.column :canal
    t.column :coordinate
    t.column :test
    t.action :edit
    t.action :destroy
  end

  def show
    @communication = Communication.find(params[:id])
    @communication.save if @communication.key.blank?

    if request.xhr?
      if params[:tab] == "shipments"
        render :partial => "shipments"
      else
        head :not_found
      end
    else
      respond_to do |format|
        format.html { session[:communication_id] = @communication.id}
        format.pdf  { send_data @communication.to_pdf }
        format.json { render :json => @communication }
        format.xml  { render :xml => @communication }
      end
    end
  end
  
  def new
    @communication = Communication.new(:client_id => params[:client_id], :nature => params[:nature])
    if @communication.newsletter?
      @communication.newsletter = Newsletter.find_by_id(params[:newsletter_id])
      @communication.client ||= @communication.newsletter.client
      if @communication.newsletter
        @communication.with_pdf     = @communication.newsletter.with_pdf
        @communication.introduction = @communication.newsletter.introduction
        @communication.conclusion   = @communication.newsletter.conclusion
        if previous = @communication.newsletter.communications.order(:created_at).last
          for attr in [:name, :subject, :title, :sender_label, :sender_email, :reply_to_email, :target_url]
            @communication.send("#{attr}=", previous.send(attr))
          end
          @communication.introduction = previous.introduction if @communication.introduction.blank?
          @communication.conclusion   = previous.conclusion if @communication.conclusion.blank?
          @communication.subject.to_s.succ! if @communication.subject.to_s.match(/\d+$/)
          @communication.title.to_s.succ! if @communication.title.to_s.match(/\d+$/)
          @communication.name.to_s.succ! if @communication.name.to_s.match(/\d+$/)
        end
      end
    elsif @communication.document?
      @communication.subject = "[NAME]"
    end
    if c = @communication.client
      @communication.sender_email = c.email
      @communication.sender_label = c.name
    end
    respond_to do |format|
      format.html { render_restfully_form(:multipart => true) }
      format.json { render :json => @communication }
      format.xml  { render :xml => @communication }
    end
  end
  
  def create
    @communication = Communication.new(params[:communication])
    unless current_user.administrator?
      @communication.client = current_user
      @communication.newsletter = current_user.newsletters.find_by_id(@communication.newsletter_id)
    end
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
    unless current_user.administrator?
      @communication.client = current_user
      @communication.newsletter = current_user.newsletters.find_by_id(@communication.newsletter_id)
    end
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


  def duplicate
    @communication = Communication.find(params[:id])
    comm = @communication.duplicate!
    redirect_to edit_communication_url(comm)
  end

  def populate
    @communication = Communication.find(params[:id])
    if request.post?
      clist = []
      if params[:import_file].to_i > 0
        name = params[:touchables_file].original_filename
        path = Rails.root.join("tmp", "codes-import.#{name}.#{rand.to_s[2..16].to_i.to_s(36)}.csv")
        File.open(path, "wb") { |f| f.write(params[:touchables_file].read) }
        lines = CSV.read(path)
        header = lines.shift
        indexes = {}
        header.each_with_index do |name, index|
          indexes[name.to_s.strip.downcase] ||= index unless name.blank?
        end
        wanted = Touchable.canals
        indexes.delete_if{|k, v| !wanted.include?(k)}
        unless indexes.size == wanted.size
          flash.now[:error] = "Fichier invalide : des colonnes sont manquantes (#{(wanted-indexes.keys).inspect})"
          return
        end
        clist = lines.collect do |line|
          wanted.inject({}) do |hash, canal|
            hash[canal] = line[indexes[canal]]
            hash
          end
        end
      else
        source = params[:touchables_list].to_s        
        clist = source.to_s.split(/\"*\s*\n+\s*\"*/).compact.collect{|x| x.to_s.mb_chars.downcase}.uniq.collect do |line|
          x = line.split(/\,/)
          x[2] ||= nil
          {"email" => x[0], "fax" => x[1], "mail" => x[2..-1].join(',')}
        end.uniq
        clist.delete_at(0) if params[:header]
      end
      test_purpose = (params[:test].to_i == 1 ? true : false)
      code  = "for infos in clist\n"
      code << "  canal = (" + @communication.client.canals_priority_array.collect do |canal| 
        "!infos['#{canal}'].blank? ? '#{canal}'"
      end.join(" : ") + " : nil)\n"
      code << "  @communication.touchables.create(:canal => canal, :coordinate => infos[canal], :test => test_purpose) unless canal.nil?\n"
      code << "end\n"
      eval(code)
      # for infos in clist
      #   canal = (!infos[p1].blank? ? infos[p1] : !infos[p2].blank? ? infos[p2] : infos[p3])
      #   @communication.touchables.create!(:canal => canal, :coordinate => infos[canal], :test => test_purpose)
      # end
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
    settings = {:mode => (params[:mode] || "test").to_sym}
    unless params[:only].blank?
      settings[:only] = params[:only].to_sym
    end
    @communication.send_shipment(settings)
    redirect_to communication_url(@communication)
  end

  def mail
    shipment = Shipment.find(params[:id])
    send_file shipment.mail.path(:original)
  end

end
