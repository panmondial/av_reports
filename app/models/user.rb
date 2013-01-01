class User < ActiveRecord::Base
	attr_accessible :first_name, :last_name, :address1, :address2, :city, :state_province, :country, :zip_postalcode, :phone, :email, :password, :password_confirmation, :email, :terms, :fs_username, :fs_password, :lead_source, :lead_source_other
	
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
	validates :lead_source, presence: true
	validates :lead_source_other, presence: true, :if => lambda { |a| a.lead_source=="Other" }
	validates_acceptance_of :terms, :message => "must be accepted"

	def create_remember_token
		self.remember_token = SecureRandom.urlsafe_base64
	end
	
	def send_password_reset
	  generate_token(:password_reset_token)
	  self.password_reset_sent_at = Time.zone.now
	  save!(:validate => false)
	  UserMailer.password_reset(self).deliver
	end
	
	def generate_token(column)
	  begin
	    self[column] = SecureRandom.urlsafe_base64
	  end while User.exists?(column => self[column])
	end
end