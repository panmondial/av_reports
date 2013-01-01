class PasswordResetsController < ApplicationController
  before_filter :check_reset_expiration, except: :update
  
  def new
  end
  
  def create
    user = User.find_by_email(params[:email])
	if user
	  user.send_password_reset
	  redirect_to root_url, :notice => "Please check your email for password reset instructions."
	else
	  flash.now[:error] = 'Invalid email address. Please try again.'
	  render :new
	end
  end
  
  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  end
  
  def update
    @user = User.find_by_password_reset_token!(params[:id])
	@user.update_attributes(params[:user])
	redirect_to root_url, :notice => "Password has been reset!"
  end
	
  private

  def check_reset_expiration
    if !params[:id].nil?
	  @user = User.find_by_password_reset_token!(params[:id]) if params[:id]
	  if @user.password_reset_sent_at < 2.hours.ago
        redirect_to new_password_reset_path, :alert => "Password reset has expired (over 2 hour response limit)."
      elsif
	    render :edit
	  end
	end
  end
  
end
