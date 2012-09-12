class AdminController < ApplicationController
  before_filter :authenticate_user!

  def index
    redirect_to user_url(current_user)
  end

end
