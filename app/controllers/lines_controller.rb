class LinesController < ApplicationController
  def index
    lines = Line.eager_load(:haiku).where("haiku_id = ?", params[:haiku_id])
    render json: lines, each_serializer: LineSerializer
  end

  def create
    line = Line.new(line_params)
    if line.save
      render json: line, status: 201
    else
      render json: '400', status: 400
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
    params.permit(:haiku_id, :content)
  end
end

