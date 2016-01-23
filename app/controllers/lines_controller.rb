class LinesController < ApplicationController
  before_action :require_login, only: [:create]

  def index
    lines = Line.eager_load(:haiku).where("haiku_id = ?", params[:haiku_id])
    render json: lines, each_serializer: LineSerializer
  end

  def new
    @haiku = Haiku.find(params[:haiku_id])
    @count = @haiku.lines.count
    @line = Line.new
  end

  def create
    @line = Line.new(line_params.merge({ haiku_id: params[:haiku_id], user_id: current_user.id }))
    if @line.save
      redirect_to root_url, notice: "Haiku line created!"
    else
      @haiku = Haiku.find(params[:haiku_id])
      @count = @haiku.lines.count
      render 'new'
    end
  end

  def update
    line = Line.find(params[:id])
    if line.update_attributes(line_params)
      render json: line
    else
      render json: '400', status: 400
    end
  end

  def show
    line = Line.find(params[:id])
    render json: line
  end

  def destroy
    line = Line.find(params[:id])
    line.destroy
    head 204
  end

  private

  def line_params
    params.require(:line).permit(:content)
  end
end

