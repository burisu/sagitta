class PiecesController < AdminController
  
  def show
    @piece = Piece.find(params[:id])
    send_file @piece.document.path(:original)
  end

  def new
    @piece = Piece.new
    if article = Article.find_by_id(params[:article_id])
      @piece.article = article
      @piece.communication = article.communication
    elsif communication = Communication.find_by_id(params[:communication_id])
      @piece.communication = communication
    end
    respond_to do |format|
      format.html { render_restfully_form(:multipart => true) }
      format.json { render :json => @piece }
      format.xml  { render :xml => @piece }
    end
  end
  
  def create
    @piece = Piece.new(params[:piece])
    respond_to do |format|
      if @piece.save
        format.html { redirect_to (params[:redirect] || communication_url(@piece.communication)) }
        format.json { render json => @piece, :status => :created, :location => @piece }
      else
        format.html { render_restfully_form(:multipart => true) }
        format.json { render :json => @piece.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @piece = Piece.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form(:multipart => true) }
    end
  end
  
  def update
    @piece = Piece.find(params[:id])
    @piece.communication = Communication.find_by_id(@piece.communication_id)
    respond_to do |format|
      if @piece.update_attributes(params[:piece])
        format.html { redirect_to (params[:redirect] || communication_url(@piece.communication)) }
        format.json { head :no_content }
      else
        format.html { render_restfully_form(:multipart => true) }
        format.json { render :json => @piece.errors, :status => :unprocessable_entity }
      end
    end
  end
  

  def destroy
    @piece = Piece.find(params[:id])
    @piece.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || communication_url(@piece.communication)) }
      format.json { head :no_content }
    end
  end

end
