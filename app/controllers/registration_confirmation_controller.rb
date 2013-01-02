class RegistrationConfirmationController < ApplicationController

  def edit
    if !params[:id].nil?
	  @user = User.find_by_registration_token!(params[:id])
	  if @user
        @user.registration_verified
        flash[:notice] = "Thank you for verifying your account. You may now login"
	  else
	    flash[:error] = "Unable to find your account." unless @user
        redirect_to signup_path
	  end
    end

    redirect_to root_url
  end
  
end
