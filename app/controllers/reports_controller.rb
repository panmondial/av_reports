require 'csv'


class ReportsController < ApplicationController
  before_filter :signed_in_user, except: :index
  helper_method :build_pedigree
  
  def end_of_line
	@filter_criteria = lambda { |ped| (ped.father_id.nil? || ped.mother_id.nil?) }
	@report_title = __method__.to_s.titleize + " Report"
	@report_description = "This report shows direct-line ancestors at the end of each branch of the family tree."
	respond_to do |format|
	  format.html {render '_report_detail', :layouts => 'reports', :locals => {:@filter_criteria => @filter_criteria } }
	  format.csv do
		build_csv
        send_data @csv_array, filename: "#{__method__}.csv"
      end
	end
  end

  def direct_line_all
	@filter_criteria = lambda { |ped| ped.id }
	@report_title = __method__.to_s.titleize + " Report"
	@report_description = "This report shows all ancestors in a direct-line relationship (ex: self, father, mother, grandfather, grandmother, etc.)"
	respond_to do |format|
	  format.html {render '_report_detail', :layouts => 'reports', :locals => {:@filter_criteria => @filter_criteria } }
	  format.csv do
		build_csv
		send_data @csv_array, filename: "#{__method__}.csv"
	  end
	end
  end

  def missing_birth_date
	@filter_criteria = lambda { |ped| !(ped.birth && ped.birth.date) }
	@report_title = __method__.to_s.titleize + " Report"
	@report_description = "This report shows all direct-line ancestors with no birth date,"
	respond_to do |format|
	  format.html {render '_report_detail', :layouts => 'reports', :locals => {:@filter_criteria => @filter_criteria } }
	  format.csv do
        build_csv	  
	    send_data @csv_array, filename: "#{__method__}.csv"
	  end
	end
  end

  def missing_birth_place
	@filter_criteria = lambda { |ped| !(ped.birth && ped.birth.place) }
	@report_title = __method__.to_s.titleize + " Report"
	@report_description = "This report shows all direct-line ancestors with no birth place."
	@report_description = "This report shows a list of all direct-line ancestors with no birth date in the FamilySearch tree."
	respond_to do |format|
	  format.html {render '_report_detail', :layouts => 'reports', :locals => {:@filter_criteria => @filter_criteria } }
	  format.csv do
		build_csv
		send_data @csv_array, filename: "#{__method__}.csv"
	  end
	end
  end

  def incomplete_birth_date
	@filter_criteria = lambda { |ped| !((Date.strptime "#{ped.birth.date.normalized}", '%d %B %Y') rescue false) }
	@report_description = "This report shows all direct-line ancestors with a partial or incomplete birth date."
	@report_title = __method__.to_s.titleize + " Report"
	respond_to do |format|
	  format.html {render '_report_detail', :layouts => 'reports', :locals => {:@filter_criteria => @filter_criteria } }
	  format.csv do
		build_csv
		send_data @csv_string, filename: "#{__method__}.csv"
	  end
	end
  end
	
  def missing_death_date
	@filter_criteria = lambda { |ped| !(ped.death && ped.death.date) }
	@report_title = __method__.to_s.titleize + " Report"
	@report_description = "This report shows all direct-line ancestors with no death date."
	respond_to do |format|
	  format.html {render '_report_detail', :layouts => 'reports', :locals => {:@filter_criteria => @filter_criteria } }
	  format.csv do
		build_csv
        send_data @csv_array, filename: "#{__method__}.csv"
	  end
	end
  end

  def missing_death_place
	@filter_criteria = lambda { |ped| !(ped.death && ped.death.place) }
	@report_title = __method__.to_s.titleize + " Report"
	@report_description = "This report shows all direct-line ancestors with no death place."
	respond_to do |format|
	  format.html {render '_report_detail', :layouts => 'reports', :locals => {:@filter_criteria => @filter_criteria } }
	  format.csv do
	    build_csv
        send_data @csv_array, filename: "#{__method__}.csv"
      end
	end
  end
	
  def incomplete_death_date
	@filter_criteria = lambda { |ped| !((Date.strptime "#{ped.death.date.normalized}", '%d %B %Y') rescue false) }
	@report_title = __method__.to_s.titleize + " Report"
	@report_description = "This report shows all direct-line ancestors with a partial or incomplete death date."
	respond_to do |format|
	  format.html {render '_report_detail', :layouts => 'reports', :locals => {:@filter_criteria => @filter_criteria } }
	  format.csv do
	    build_csv
		send_data @csv_array, filename: "#{__method__}.csv"
	  end
	end
  end
	
  require 'ruby-fs-stack'
  FamilyTreeV2 = Org::Familysearch::Ws::Familytree::V2::Schema

    def build_pedigree
	  subdomain = Rails.env.production? ? 'sandbox' : 'sandbox'
	  #subdomain = Rails.env.production? ? 'api' : 'sandbox'
	  @com = FsCommunicator.new(
	    :domain => "https://#{subdomain}.familysearch.org",
	    :handle_throttling => false,
	    :session => session[:api_session_id]
	  )

	  # TODO: Check for session instead? Handle invalid session exception from ruby-fs-stack (401 Unauthorized)?
	    #@my_pedigree = @com.familytree_v2.pedigree :me
		
		
	  @my_pedigree = Rails.cache.fetch("fs_root_ids", expires_in: 5.minutes) do
		@com.familytree_v2.pedigree :me
	  end
	  
	  # @my_pedigree.continue_ids.each_slice(2) do |ids|
	    # pedigrees = @com.familytree_v2.pedigree ids
		# pedigrees.each do |ped|
		  # @my_pedigree.injest ped
		# end
	  # end
	  	  
	  Rails.cache.fetch("fs_ids", expires_in: 5.minutes) do
	    @my_pedigree.continue_ids.each_slice(2) do |ids|
	      pedigrees = @com.familytree_v2.pedigree ids
		  pedigrees.each do |ped|
		    @my_pedigree.injest ped
		  end
	    end
	  end
	  
	  @pedigree = @my_pedigree
      @full_pedigree = FamilyTreeV2::Pedigree.new
	  # @persons = @com.familytree_v2.person @pedigree.person_ids, :parents => 'all', :events=> 'standard', :names=> 'summary', :families=> 'summary'
	  
	  @persons = Rails.cache.fetch("fs_detail", expires_in: 5.minutes) do
	    @com.familytree_v2.person @pedigree.person_ids, :parents => 'all', :events=> 'standard', :names=> 'summary', :families=> 'summary'
	  end
	  
	  @persons.each do |person|
  	    @full_pedigree << person
	  end
  
	  @pedigree = @full_pedigree
    end
	
  def build_csv
	@csv_array = CSV.generate do |csv|
      csv << ['FamilySearch ID', 'First Name', 'Last Name', 'Gender', 'Birth Date', 'Birth Place', 'Death Date', 'Death Place']
      build_pedigree.persons.find_all(&@filter_criteria).each do |ped|
        csv << [ped.id, \
          (ped.assertions.names[0].value.forms[0].pieces.select {|fn| fn.type=="Given"}.collect {|fn| fn.value.to_s}.join(" ") \
	        if ped.assertions && ped.assertions.names && ped.assertions.names[0].value && ped.assertions.names[0].value.forms[0] \
	          && ped.assertions.names[0].value.forms[0].pieces[0]), \
  	      (ped.assertions.names[0].value.forms[0].pieces.select {|fn| fn.type=="Family"}.collect {|fn| fn.value.to_s}.join(" ") \
	        if ped.assertions && ped.assertions.names && ped.assertions.names[0].value && ped.assertions.names[0].value.forms[0] \
	          && ped.assertions.names[0].value.forms[0].pieces[0]), \
		  ped.gender, \
		  (ped.birth.date.normalized if ped.birth && ped.birth.date && ped.birth.date.normalized), \
		  (ped.birth.place.normalized.value if ped.birth && ped.birth.place && ped.birth.place.normalized && ped.birth.place.normalized.value), \
		  (ped.death.date.normalized if ped.death && ped.death.date && ped.death.date.normalized), \
		  (ped.death.place.normalized.value if ped.death && ped.death.place && ped.death.place.normalized && ped.death.place.normalized.value)] 
      end
    end 
  end

end
