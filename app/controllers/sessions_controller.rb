class SessionsController < ApplicationController

	def new
	end
	
	def create
		user = User.find_by_email(params[:email].downcase)
		store_location_login
		if user && user.authenticate(params[:password])
			if params[:remember_me]
			  sign_in user
			else
			  sign_in_temp user
			end
			flash[:success] = "Successfully logged in!"
			redirect_back_login_or root_url
		else
			flash.now[:error] = 'Invalid email/password combination'
			render 'new'
			
		end
	end
	
	def destroy
		sign_out
		redirect_to root_url, :notice => "Logged out!"
	end
end
