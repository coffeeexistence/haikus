class HaikusController < ApplicationController
  before_action :require_login, only: [:create, :edit, :update]

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
    if @haiku.save
      if !email_entered.blank?
        begin
          invited = current_user.friend_by_email(email_entered)
          UserMailer.invite_email(invited, current_user, @haiku).deliver_now
          flash[:notice] = "Haiku line created!"
        rescue Net::SMTPFatalError => e
          flash[:notice] = "Friend was not invited due to invalid email!"
        end
      end
     redirect_to new_haiku_line_path(@haiku)
    else
      render "new"
    end
  end

  def edit
    @haiku = Haiku.find(params[:id])
  end

  def update
    @haiku = Haiku.find(params[:id])
    if @haiku.update(haiku_params)
      flash[:notice] = "Your haiku is completed!"
      redirect_to haiku_path(@haiku)
    else
      render :edit
    end
  end

  def show
    @haiku = Haiku.find(params[:id])
  end

  private

  def haiku_params
    params.require(:haiku).permit(lines_attributes: [:id, :content])
  end

  def email_entered
    params.permit(:email)[:email]
  end
end
