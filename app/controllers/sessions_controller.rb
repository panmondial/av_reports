class SessionsController < ApplicationController

  def new
  end
	
  def create
    user = User.find_by_username(auth_hash[:uid])
    store_location_login
    
	sign_in_temp user
	session[:api_session_id] = auth_hash.credentials.token # should we store the API session id in cookie?
	flash[:success] = "Successfully logged in!"
    redirect_back_or(root_url)
  end
  
  def destroy
    sign_out
    redirect_to root_url, :notice => "Logged out!"
  end

	
  # def create_omniauth
    # auth_hash = request.env['omniauth.auth']

    # user = User.find_by_username(auth_hash[:uid]) || User.create_with_omniauth(auth_hash)
    # sign_in_temp user
    # session[:api_session_id] = auth_hash.credentials.token # should we store the API session id in cookie?

    # flash[:success] = 'Successfully logged in!'
    # redirect_back_or(root_url)
  # end
  
  def create_omniauth
    auth_hash = request.env['omniauth.auth']
    
	user = User.find_by_username(auth_hash[:uid])
	if user
	  sign_in_temp user
      session[:api_session_id] = auth_hash.credentials.token # should we store the API session id in cookie?
 
      flash[:success] = 'Successfully logged in!'
      redirect_back_or(root_url)
	else
	  session[:auth_hash]=auth_hash
	  redirect_to signup_path
	end
  end

end
