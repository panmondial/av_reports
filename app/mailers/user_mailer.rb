class UserMailer < ActionMailer::Base
  default from: "info@arborvitaesoftware.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user)
    @user = user
	mail :to => user.email, :subject => "Arbor Vitae Password Reset"
  end
  
  def registration_confirmation(user)
    @user = user
	mail :to => user.email, :subject => "Arbor Vitae Registration Confirmation Required"
  end
  
  def registration_welcome(user)
    @user = user
	attachments.inline["arbor_vitae_logo.jpg"] = File.read("#{Rails.root}/app/assets/images/arbor_vitae_logo_sm.jpg")
	mail :to => user.email, :subject => "Welcome to Arbor Vitae - Registration Complete!"
  end
end
