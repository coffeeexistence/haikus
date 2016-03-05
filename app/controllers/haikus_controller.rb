class HaikusController < ApplicationController
  before_action :require_login, only: [:create]

  def index
    params[:scope_param] ||= "all"
    @haikus = Haiku.all
    @my_haikus = current_user ? current_user.haikus.send("#{params[:scope_param]}") : []
    @scopes = ["complete", "in_progress", "all"] - ["#{params[:scope_param]}"]
  end

  def new
    @haiku = Haiku.new
    @haiku.lines.build
  end

  def create
    @haiku = Haiku.new(haiku_params)
    @haiku.lines.last.user = current_user
    unless email_entered.empty?
      if @haiku.save
        invited = current_user.friend_by_email(email_entered)
        UserMailer.invite_email(invited, current_user, @haiku).deliver_now
        flash[:notice] = "Haiku line created!"
        redirect_to new_haiku_line_path(@haiku)
      else
        render :new
      end
    else
      flash.now[:error] = "Email cannot be blank."
      render :new
    end
  end

  private

  def haiku_params
    params.require(:haiku).permit(lines_attributes: [:content])
  end

  def email_entered
    params.permit(:email)[:email]
  end
end
