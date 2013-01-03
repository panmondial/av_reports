class RegistrationConfirmationController < ApplicationController

  def edit
    if !params[:id].nil?
	  @user = User.find_by_registration_token(params[:id])
	  if @user && @user.verified == false
        @user.registration_verified
        flash[:notice] = "Thank you for verifying your account. You may now login."
		UserMailer.registration_welcome(@user).deliver
	  elsif @user && @user.verified == true
	    flash[:notice] = "Account has already been verified. Please login."
	  else
	    flash[:error] = "Invalid request. Please sign in or register."
        #redirect_to signup_path
	  end
    end

    redirect_to root_url
  end
  
end
