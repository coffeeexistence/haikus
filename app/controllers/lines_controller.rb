class LinesController < ApplicationController
  before_action :require_login, only: [:create]

  def new
    @haiku = Haiku.find(params[:haiku_id])
    @count = @haiku.lines.count
    @line = Line.new
  end

  def create
    @haiku = Haiku.find(params[:haiku_id])
    redirect_to root_url, notice: "No more than three lines!" and return unless @haiku.lines_count_valid?

    @line = @haiku.lines.build(line_params)
    @line.user = current_user
    if @line.save
      flash[:notice] = "Haiku line created!"
      redirect_to new_haiku_line_path(@haiku)
    else
      @count = @haiku.lines.count
      render 'new'
    end
  end

  private

  def line_params
    params.require(:line).permit(:content)
  end
end

