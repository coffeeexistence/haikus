class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def invite_email(invited, user, haiku)
    @user = user
    @url = new_haiku_line_url(haiku, host: "haikus.example.com")
    mail(to: invited.email, subject: "Come write Haiku")
  end
end
