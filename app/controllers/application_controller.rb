class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user != nil
  end

  def require_login
    unless logged_in?
      redirect_to log_in_url, notice: "Log in to create a Haiku!"
    end
  end
end
