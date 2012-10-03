class ArticlesController < AdminController
  
  def new
    @article = Article.new(:readmore_label => "En savoir plus")
    if communication = Communication.find_by_id(params[:communication_id])
      @article.communication = communication
      @article.newsletter = communication.newsletter
    end
    respond_to do |format|
      format.html { render_restfully_form(:multipart => true) }
      format.json { render :json => @article }
      format.xml  { render :xml => @article }
    end
  end
  
  def create
    @article = Article.new(params[:article])
    @article.communication = Communication.find_by_id(@article.communication_id)
    respond_to do |format|
      if @article.save
        format.html { redirect_to (params[:redirect] || communication_url(@article.communication)) }
        format.json { render json => @article, :status => :created, :location => @article }
      else
        format.html { render_restfully_form(:multipart => true) }
        format.json { render :json => @article.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @article = Article.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form(:multipart => true) }
    end
  end
  
  def update
    @article = Article.find(params[:id])
    @article.communication = Communication.find_by_id(@article.communication_id)
    respond_to do |format|
      if @article.update_attributes(params[:article])
        format.html { redirect_to (params[:redirect] || communication_url(@article.communication)) }
        format.json { head :no_content }
      else
        format.html { render_restfully_form(:multipart => true) }
        format.json { render :json => @article.errors, :status => :unprocessable_entity }
      end
    end
  end
  

  def up
    @article = Article.find(params[:id])
    @article.move_higher
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || communication_url(@article.communication, :anchor => @article.title.parameterize)) }
      format.json { head :no_content }
    end
  end
  

  def down
    @article = Article.find(params[:id])
    @article.move_lower
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || communication_url(@article.communication, :anchor => @article.title.parameterize)) }
      format.json { head :no_content }
    end
  end
  

  def destroy
    @article = Article.find(params[:id])
    @article.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || communication_url(@article.communication)) }
      format.json { head :no_content }
    end
  end

end
