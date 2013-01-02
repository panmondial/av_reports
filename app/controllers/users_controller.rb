class UsersController < ApplicationController
	before_filter :signed_in_user, only: [:edit, :update]
	before_filter :correct_user, only: [:edit, :show, :update]

	def show
		@user = User.find(params[:id])
	end
  
	def new
		@user = User.new
	end
	
	def create
		@user = User.new(params[:user])
		if @user.save
			flash[:notice] = "Thank you for signing up with Arbor Vitae. An email has been sent to you with instructions on how to complete your registration."
			@user.send_registration_confirmation if @user
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
