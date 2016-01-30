class HaikusController < ApplicationController
  before_action :require_login, only: [:create]

  def index
    @haikus = Haiku.all
  end

  def new
    @haiku = Haiku.new
    @haiku.lines.build
  end

  def create
    @haiku = Haiku.new(haiku_params)
    @haiku.lines.last.user = current_user
    if @haiku.save
      if email_entered
        invited = current_user.friend_by_email(email_entered)
        UserMailer.invite_email(invited, current_user, @haiku).deliver_now
      end
      redirect_to root_url, notice: "Haiku created!"
    else
      render "new"
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
