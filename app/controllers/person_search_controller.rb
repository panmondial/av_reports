require 'ruby-fs-stack'

class PersonSearchController < ApplicationController
  
  helper_method :search
  
  def index
  end
  
  def search
    subdomain = Rails.env.production? ? 'sandbox' : 'sandbox'
	  #subdomain = Rails.env.production? ? 'api' : 'sandbox'
	  com = FsCommunicator.new(
	    :domain => "https://#{subdomain}.familysearch.org",
	    :handle_throttling => true,
	    :session => session[:api_session_id]
	  )
	  
	search = com.familytree_v2.search (:givenName => "John", 
                                      :familyName => "Doe",
                                      :birthDate => "12 Jun 1812",
                                      :birthPlace => "Virginia, United States",
                                      :father => {:givenName => "Robert"},
                                      :maxResults => 10)
       
  
    respond_to do |format|
	  format.html {render '_search_results' }
	end
  
  end
  
end
