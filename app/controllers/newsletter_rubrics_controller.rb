class NewsletterRubricsController < AdminController
  
  def new
    @newsletter_rubric = NewsletterRubric.new(:newsletter_id => current_user.newsletters.find_by_id(params[:newsletter_id]).id)
    respond_to do |format|
      format.html { render_restfully_form(:multipart => true) }
      format.json { render :json => @newsletter_rubric }
      format.xml  { render :xml => @newsletter_rubric }
    end
  end
  
  def create
    @newsletter_rubric = NewsletterRubric.new(params[:newsletter_rubric])
    @newsletter_rubric.newsletter = current_user.newsletters.find_by_id(@newsletter_rubric.newsletter_id) unless current_user.administrator?
    respond_to do |format|
      if @newsletter_rubric.save
        format.html { redirect_to (params[:redirect] || newsletter_url(@newsletter_rubric.newsletter)) }
        format.json { render json => @newsletter_rubric, :status => :created, :location => @newsletter_rubric }
      else
        format.html { render_restfully_form(:multipart => true) }
        format.json { render :json => @newsletter_rubric.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @newsletter_rubric = NewsletterRubric.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form(:multipart => true) }
    end
  end
  
  def update
    @newsletter_rubric = NewsletterRubric.find(params[:id])
    @newsletter_rubric.newsletter = current_user.newsletters.find_by_id(@newsletter_rubric.newsletter_id) unless current_user.administrator?
    respond_to do |format|
      if @newsletter_rubric.update_attributes(params[:newsletter_rubric])
        format.html { redirect_to (params[:redirect] || newsletter_url(@newsletter_rubric.newsletter)) }
        format.json { head :no_content }
      else
        format.html { render_restfully_form(:multipart => true) }
        format.json { render :json => @newsletter_rubric.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @newsletter_rubric = NewsletterRubric.find(params[:id])
    @newsletter_rubric.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || newsletter_url(@newsletter_rubric.newsletter)) }
      format.json { head :no_content }
    end
  end

end
