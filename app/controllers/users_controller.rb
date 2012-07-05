class UsersController < AdminController

  list do |t|
    t.column :full_name, :url => true
    t.column :email    
    t.column :administrator
    t.action :edit
    t.action :destroy
  end

  def index
  end

  list :communications do |t|
    t.column :name, :url => true
    t.column :planned_on
  end

  list :untouchables do |t|
    t.column :email
  end


  def show
    @user = User.find(params[:id])
  end
  
  def new
    @user = User.new()
    respond_to do |format|
      format.html { render_restfully_form }
      format.json { render :json => @user }
      format.xml  { render :xml => @user }
    end
  end
  
  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        format.html { redirect_to (params[:redirect] || users_url) }
        format.json { render json => @user, :status => :created, :location => @user }
      else
        format.html { render_restfully_form }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @user = User.find(params[:id])
    respond_to do |format|
      format.html { render_restfully_form }
    end
  end
  
  def update
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to (params[:redirect] || users_url) }
        format.json { head :no_content }
      else
        format.html { render_restfully_form }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    respond_to do |format|
      format.html { redirect_to (params[:redirect] || users_url) }
      format.json { head :no_content }
    end
  end

end
