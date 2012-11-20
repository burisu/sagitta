class AdminController < ApplicationController
  before_filter :authenticate_user!

  layout "admin"

  def index
    redirect_to users_url
  end

  def toggle_tab
    if session[:tabbox].is_a?(Hash)
      if session[:tabbox][params[:id]]
        session[:tabbox][params[:id]] = params[:tab]
      end
    end
    render :inline => ''
  end

end
