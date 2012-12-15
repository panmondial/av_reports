module SessionsHelper

	def sign_in(user)
		cookies.permanent[:remember_token] = user.remember_token
		self.current_user = user
	end
	
	def sign_in_temp(user)
		cookies[:remember_token] = user.remember_token
		self.current_user = user
	end
	
	def signed_in?
		!current_user.nil?
	end
	
	def current_user=(user)
		@current_user = user
	end
	
	def current_user
		@current_user ||= User.find_by_remember_token(cookies[:remember_token]) if cookies[:remember_token]
	end
	
	def current_user?(user)
		user == current_user
	end
	
	def sign_out
		self.current_user = nil
		cookies.delete(:remember_token)
	end
	
	def redirect_back_or(default)
		redirect_to(session[:return_to] || default)
		session.delete(:return_to)
	end

	def store_location
		session[:return_to] = request.url
	end
	
	def store_location_login
	  session[:referral_url] = request.referer
	end
	
	def redirect_back_login_or(default)
	  #if url_for(signin_path) == URI(session[:referral_url]).path
	  if URI(signin_path).path == URI(session[:referral_url]).path
	    redirect_to root_url
	  else
		redirect_to(session[:referral_url] || default)
	  end
	  session.delete(:referral_url)
	end
end
