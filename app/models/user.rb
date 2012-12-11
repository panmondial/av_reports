class User < ActiveRecord::Base
	attr_accessible :first_name, :last_name, :address1, :address2, :city, :state_province, :country, :zip_postalcode, :phone, 
	    :email, :password, :password_confirmation, :email, :terms, :fs_username, :fs_password
	
	has_secure_password

	before_save { |user| user.email = email.downcase }
	before_save :create_remember_token

	validates :first_name, presence: true, length: { maximum: 50 }
	validates :last_name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence:   true,
            format:     { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
	validates :password, presence: true, length: { minimum: 8 }
	validates :password_confirmation, presence: true
	validates_acceptance_of :terms

	def create_remember_token
		self.remember_token = SecureRandom.urlsafe_base64
	end
end