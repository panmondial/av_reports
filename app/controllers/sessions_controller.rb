class SessionsController < ApplicationController

  def new
  end
	
  def create
    user = User.find_by_email(params[:email].downcase)
	store_location_login
	if user && user.verified == true
      if user && user.authenticate(params[:password])
	    if params[:remember_me]
          sign_in user
        else
          sign_in_temp user
        end
        flash[:success] = "Successfully logged in!"
        redirect_back_login_or root_url
      else
        flash[:error] = 'Invalid password. Please try again.'
        redirect_to signin_url
      end
	elsif user && user.verified == false
	  flash[:error] = "Your registration has not yet been confirmed. Please find the email sent to you with the subject: 'Action Required: Arbor Vitae Registration Confirmation', and follow the instructions to complete your registration."
	  redirect_back_login_or root_url
	else
	  flash[:error] = %Q[Invalid email. If you have not yet registered with Arbor Vitae, please visit the <a href="/signup">signup page</a>.].html_safe
	  redirect_back_login_or root_url
	end
  end
  
  # def create
    # user = User.find_by_email(params[:email].downcase)
	# store_location_login
    # if user && user.authenticate(params[:password])
	  # if params[:remember_me]
        # sign_in user
      # else
        # sign_in_temp user
      # end
      # flash[:success] = "Successfully logged in!"
      # redirect_back_login_or root_url
    # else
      # flash.now[:error] = 'Invalid email/password combination'
      # render 'new'
    # end
  # end
	
	def destroy
		sign_out
		redirect_to root_url, :notice => "Logged out!"
	end

	def create_omniauth
		@user = User.find_or_create_from_auth_hash(auth_hash)
		sign_in_temp @user
		session[:api_session_id] = auth_hash.credentials.token
		flash[:success] = "Successfully logged in!"
		redirect_back_or root_url
	end

	private

	def auth_hash
		request.env["omniauth.auth"]
	end

end
