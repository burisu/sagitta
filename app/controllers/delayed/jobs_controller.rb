class Delayed::JobsController < AdminController

  def index
  end

  def destroy
    job = Delayed::Job.find(params[:id])
    job.destroy
    if Delayed::Job.count.zero?
      redirect_to params[:redirect] || users_url
    else
      redirect_to delayed_jobs_url(:redirect => params[:redirect])
    end
  end
end
