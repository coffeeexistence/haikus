class UsersController < ApplicationController
  before_action :require_login, only: [:add_friend]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to root_url, notice: "Signed up!"
    else
      render "new"
    end
  end

  def edit
    if logged_in?
      @user = current_user
    else
      redirect_to root_path, notice: "Please log in before proceeding"
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      redirect_to root_path, notice: "Profile updated"
    else
      render 'edit'
    end
  end

  def forgot_password
    @user = User.new
  end

  def enter_email
    user = User.find_by(email: email_entered)
    if user
      user.forgot_password
      UserMailer.reset_password(user.id.to_s).deliver_now
      flash[:notice] = "You will receive an email shortly, with instructions on how to reset your password"
      redirect_to root_path
    elsif email_entered.blank?
      flash[:error] = "Can't leave this blank."
      redirect_to forgot_password_path
    else
      flash[:error] = "#{email_entered} is not associated with an account in our system. Enter a different email, or #{view_context.link_to('click here', sign_up_path)} to create an account.".html_safe
      redirect_to forgot_password_path
    end
  end

  def add_friend
    invited = current_user.friend_by_email(email_entered)
    redirect_to new_haiku_url
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :current_password)
  end

  def email_entered
    params.require(:user).permit(:email)[:email]
  end
end
