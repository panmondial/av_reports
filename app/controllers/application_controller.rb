class ApplicationController < ActionController::Base
	protect_from_forgery
	include SessionsHelper

        rescue_from RubyFsStack::Unauthorized, :with => :fs_unauthorized
	
	private
	
		def signed_in_user
			unless signed_in?
				store_location
				redirect_to signin_url, notice: "Please sign in."
			end
		end
		
		def correct_user
			@user = User.find(params[:id])
			#redirect_to(root_path) unless current_user?(@user)
			if current_user?(@user)
			  true
			else
			  flash[:error] = 'Invalid access.'
			  redirect_to(root_path)
			end
		end
	

  def fs_unauthorized
    store_location
    sign_out

    flash[:error] = 'Your session has expired! Please login again to continue.'
    #redirect_to root_path
    redirect_to controller: params[:controller]
  end

end
