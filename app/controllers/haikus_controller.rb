class HaikusController < ApplicationController
  before_action :require_login, only: [:create]

  def new
    @haiku = Haiku.new
    @haiku.lines.build
  end

  def create
    @haiku = Haiku.new(haiku_params)
    @haiku.lines.last.user = current_user
    if @haiku.save
      redirect_to root_url, notice: "Haiku created!"
    else
      render "new"
    end
  end

  private

  def haiku_params
    params.require(:haiku).permit(lines_attributes: [:content])
  end

  def require_login
    unless logged_in?
      redirect_to log_in_url, notice: "Log in to create a Haiku!"
    end
  end
end
