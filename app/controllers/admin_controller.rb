class AdminController < ApplicationController
  before_filter :authenticate_user!

  layout "admin"

  def index
    redirect_to users_url
  end

end
