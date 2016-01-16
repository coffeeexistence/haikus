class UsersController < ApplicationController
  def create
    user = User.new(user_params)
    if user.save
      render json: user
    else
     render json: '400', status: 400
    end
  end

  def destroy
    user = User.find_by(id: params[:id])
    user.destroy

    head 204
  end

  private

  def user_params
    params.permit(:email, :password)
  end
end
