class LinesController < ApplicationController
  before_action :require_login, only: [:create]

  def new
    @haiku = Haiku.find(params[:haiku_id])
    @count = @haiku.lines.count
    @line = Line.new
  end

  def create
    @line = Line.new(line_params.merge({ haiku_id: params[:haiku_id] }))
    @line.user = current_user
    if @line.save
      redirect_to root_url, notice: "Haiku line created!"
    else
      @haiku = Haiku.find(params[:haiku_id])
      @count = @haiku.lines.count
      render 'new'
    end
  end

  private

  def line_params
    params.require(:line).permit(:content)
  end
end

