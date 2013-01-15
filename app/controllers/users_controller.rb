class UsersController < ApplicationController
	before_filter :signed_in_user, only: [:edit, :update]
	before_filter :correct_user, only: [:edit, :show, :update]

	def show
		@user = User.find(params[:id])
	end
  
	def new
		#auth_hash = request.env['omniauth.auth']
		# @user = User.new :first_name => auth_hash.info[:first_name], :last_name => auth_hash.info[:last_name], :email => auth_hash.info[:email], :username => auth_hash[:uid]
		auth_hash = session[:auth_hash]
		@user = User.new :first_name => auth_hash.info[:first_name], :last_name => auth_hash.info[:last_name], :email => auth_hash.info[:email], :username => auth_hash[:uid]
	end
	
	def create
		@user = User.new(params[:user])
		if @user.save
		  sign_in_temp @user
		  session[:api_session_id] = auth_hash.credentials.token # should we store the API session id in cookie?
	      flash[:success] = "Successfully logged in!"
		  redirect_to root_url
		else
			render 'new'
		end
	end
	
	def edit
		@user = User.find(params[:id])
	end
	
	def update
		if @user.update_attributes(params[:user])
			flash[:success] = "Profile updated"
			sign_in @user
			redirect_to @user
		else
			render 'edit'
		end
	end
	
end
