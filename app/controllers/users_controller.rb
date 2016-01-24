class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to root_url, :notice => "Signed up!"
    else
      render "new"
    end
  end

  def destroy
    user = User.find_by(id: params[:id])
    user.destroy

    head 204
  end

  def forgot_password
    @user = User.new
  end

  def enter_email
    user = User.find_by(email: params[:user][:email])
    if user
      user.forgot_password
      flash[:notice] = "You will receive an email shortly, with instructions on how to reset your password"
      redirect_to root_path
    else
      redirect_to forgot_password_path
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
