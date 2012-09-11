class NewslettersController < AdminController

  list :rubrics, :model => :newsletter_rubric, :conditions => {:newsletter_id => ["session[:current_newsletter_id]"]} do |t|
    t.column :name
    t.column :color
    t.column :border
    t.action :edit
    t.action :destroy
  end

  list :communications, :conditions => {:newsletter_id => ["session[:current_newsletter_id]"]} do |t|
    t.column :name, :url => true
    t.column :planned_on
    t.column :updated_at
    t.action :edit
    t.action :destroy
  end

  def show
    @newsletter = Newsletter.find(params[:id])
    respond_to do |format|
      format.html { session[:current_newsletter_id] = @newsletter.id }
      format.json { render :json => @newsletter }
      format.xml  { render :xml => @newsletter }
    end
  end

  
  def new
    @newsletter = Newsletter.new(:client_id => params[:client_id])
    respond_to do |format|
      format.html { render_restfully_form(:multipart => true) }
      format.json { render :json => @newsletter }
      format.xml  { render :xml => @newsletter }
    end
  end
  
  def create
    @newsletter = Newsletter.new(params[:newsletter])
    @newsletter.client = current_user unless current_user.administrator?
    respond_to do |format|
      if @newsletter.save
        format.html { redirect_to (params[:redirect] || newsletter_url(@newsletter)) }
        format.json { render json => @newsletter, :status => :created, :location => @newsletter }
      else
        format.html { render_restfully_form(:multipart => true) }
        format.json { render :json => @newsletter.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @newsletter = Newsletter.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form(:multipart => true) }
    end
  end
  
  def update
    @newsletter = Newsletter.find(params[:id])
    @newsletter.client = current_user unless current_user.administrator?
    respond_to do |format|
      if @newsletter.update_attributes(params[:newsletter])
        format.html { redirect_to (params[:redirect] || newsletter_url(@newsletter)) }
        format.json { head :no_content }
      else
        format.html { render_restfully_form(:multipart => true) }
        format.json { render :json => @newsletter.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @newsletter = Newsletter.find(params[:id])
    @newsletter.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || newsletter_url(@newsletter)) }
      format.json { head :no_content }
    end
  end

end
