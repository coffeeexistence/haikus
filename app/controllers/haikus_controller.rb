class HaikusController < ApplicationController

  def new
    @haiku = Haiku.new
    @haiku.lines.build
  end

  def create
    @haiku = Haiku.new(haiku_params)
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

end
