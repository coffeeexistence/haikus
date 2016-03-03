class UserMailer < ApplicationMailer
  default from: "support@haikus.com"

  def invite_email(invited, user, haiku)
    @user = user
    @url = new_haiku_line_url(haiku, :user => invited.password_salt)
    mail(to: invited.email, subject: "Come write Haiku")
  end

  def reset_password(id)
    @user = User.find(id)
    mail(to: @user.email)
  end
end
