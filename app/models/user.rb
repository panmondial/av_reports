class User < ActiveRecord::Base
	attr_accessible :email, :password, :password_confirmation,
		:first_name, :last_name, :phone, :address1, :address2, :city, 
		:country, :state_province, :zip_postalcode, :lead_source
		
	has_secure_password

	before_save { |user| user.email = email.downcase }
	before_save :create_remember_token

	validates :first_name, presence: true, length: { maximum: 50 }
	validates :last_name, presence: true, length: { maximum: 50 }
	validates :phone, presence: true, length: { maximum: 20 }
	validates :address1, presence: true, length: { maximum: 50 }
	validates :city, presence: true, length: { maximum: 50 }
	validates :country, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence:   true,
            format:     { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
	validates :password, presence: true, length: { minimum: 6 }
	validates :password_confirmation, presence: true
	
private

	def create_remember_token
		self.remember_token = SecureRandom.urlsafe_base64
	end
end