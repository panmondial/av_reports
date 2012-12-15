require 'csv'

class ReportsController < ApplicationController
  before_filter :signed_in_user, except: :index
  
  helper_method :build_pedigree
  helper SessionsHelper
  
  	def index
		@dog = "Hello, how are you today?"
		@letterarray = ("a".."z").to_a
		@numberarray = (1..26).to_a
	end
	
	def launch_build_file
		Process.spawn("ruby #{Rails.root}/lib/reports/build.rb")
		redirect_to reports_path
	end
		
	def end_of_line
	  @method_name = "end_of_line"
	  @filter_criteria = lambda { |ped| (ped.father_id.nil? || ped.mother_id.nil?) }
	  @report_title = "End-of-Line Report"
	  @report_description = "This report shows direct-line ancestors at the end of each branch of the family tree."
	  respond_to do |format|
	    format.html {render '_report_detail', :layouts => 'reports', :locals => {:@filter_criteria => @filter_criteria } }
		format.csv do
		  csv_string = CSV.generate do |csv|
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
          send_data csv_string, filename: 'End_of_Line.csv'		  
		end
	  end
	end
	
	def direct_line_all
	  @method_name = "direct_line_all"
	  @filter_criteria = lambda { |ped| ped.id }
	  @people = BuildPedigree.build_pedigree.persons.find_all(&@filter_criteria)
	  @report_title = "Direct Line Report"
	  @report_description = "This report shows all ancestors in a direct-line relationship (ex: self, father, mother, grandfather, grandmother, etc.)"
	  respond_to do |format|
	    format.html {render '_report_detail', :layouts => 'reports', :locals => {:@filter_criteria => @filter_criteria } }
		format.csv do
		  csv_string = CSV.generate do |csv|
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
          send_data csv_string, filename: 'direct_line_all.csv'		  
		end
	  end
	end
	
	def missing_birth_date
	  @method_name = "missing_birth_date"
	  @filter_criteria = lambda { |ped| !(ped.birth && ped.birth.date) }
	  @report_title = "Missing Birth Date Report"
	  @report_description = "This report shows all direct-line ancestors with no birth date,"
	  respond_to do |format|
	    format.html {render '_report_detail', :layouts => 'reports', :locals => {:@filter_criteria => @filter_criteria } }
		format.csv do
		  csv_string = CSV.generate do |csv|
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
          send_data csv_string, filename: 'missing_bith_date.csv'		  
		end
	  end
	end
	
	def missing_birth_place
	  @method_name = "missing_birth_place"
	  @filter_criteria = lambda { |ped| !(ped.birth && ped.birth.place) }
	  @report_title = "Missing Birth Place Report"
	  @report_description = "This report shows all direct-line ancestors with no birth place."
	  @report_description = "This report shows a list of all direct-line ancestors with no birth date in the FamilySearch tree."
	  respond_to do |format|
	    format.html {render '_report_detail', :layouts => 'reports', :locals => {:@filter_criteria => @filter_criteria } }
		format.csv do
		  csv_string = CSV.generate do |csv|
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
          send_data csv_string, filename: 'missing_birth_place.csv'		  
		end
	  end
	end
	
	def incomplete_birth_date
	  @method_name = "incomplete_birth_date"
	  @filter_criteria = lambda { |ped| !((Date.strptime "#{ped.birth.date.normalized}", '%d %B %Y') rescue false) }
	  @report_description = "This report shows all direct-line ancestors with a partial or incomplete birth date."
	  @report_title = "Incomplete Birth Date Report"
	  respond_to do |format|
	    format.html {render '_report_detail', :layouts => 'reports', :locals => {:@filter_criteria => @filter_criteria } }
		format.csv do
		  csv_string = CSV.generate do |csv|
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
          send_data csv_string, filename: 'incomplete_birth_date.csv'		  
		end
	  end
	end
	
	def missing_death_date
	  @method_name = "missing_death_date"
	  @filter_criteria = lambda { |ped| !(ped.death && ped.death.date) }
	  @report_title = "Missing Death Date Report"
	  @report_description = "This report shows all direct-line ancestors with no death date."
	  respond_to do |format|
	    format.html {render '_report_detail', :layouts => 'reports', :locals => {:@filter_criteria => @filter_criteria } }
		format.csv do
		  csv_string = CSV.generate do |csv|
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
          send_data csv_string, filename: 'missing_death_date.csv'		  
		end
	  end
	end
	
	def missing_death_place
	  @method_name = "missing_death_place"
	  @filter_criteria = lambda { |ped| !(ped.death && ped.death.place) }
	  @report_title = "Missing Death Place Report"
	  @report_description = "This report shows all direct-line ancestors with no death place."
	  respond_to do |format|
	    format.html {render '_report_detail', :layouts => 'reports', :locals => {:@filter_criteria => @filter_criteria } }
		format.csv do
		  csv_string = CSV.generate do |csv|
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
          send_data csv_string, filename: 'missing_death_place.csv'		  
		end
	  end
	end
	
	def incomplete_death_date
	  @method_name = "incomplete_death_date"
	  @filter_criteria = lambda { |ped| !((Date.strptime "#{ped.death.date.normalized}", '%d %B %Y') rescue false) }
	  @report_title = "Incomplete Death Date Report"
	  @report_description = "This report shows all direct-line ancestors with a partial or incomplete death date."
	  respond_to do |format|
	    format.html {render '_report_detail', :layouts => 'reports', :locals => {:@filter_criteria => @filter_criteria } }
		format.csv do
		  csv_string = CSV.generate do |csv|
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
          send_data csv_string, filename: 'incomplete_death_date.csv'		  
		end
	  end
	end
	
	def new
	end	
	
	
	require 'ruby-fs-stack'
	FamilyTreeV2 = Org::Familysearch::Ws::Familytree::V2::Schema

    def build_pedigree
	  @com = FsCommunicator.new :domain => 'https://sandbox.familysearch.org', :handle_throttling => true    
	  
	  if authenticate_me(@com)
	    @my_pedigree = @com.familytree_v2.pedigree :me
	  
	    @my_pedigree.continue_ids.each_slice(2) do |ids|
		  pedigrees = @com.familytree_v2.pedigree ids
		  pedigrees.each do |ped|
		    @my_pedigree.injest ped
		  end
	    end
	  
	    @pedigree = @my_pedigree
        @full_pedigree = FamilyTreeV2::Pedigree.new
	    @persons = @com.familytree_v2.person @pedigree.person_ids#, :parents => 'all', :events=> 'standard', :names=> 'summary', :families=> 'summary'

	    @persons.each do |person|
  	      @full_pedigree << person
	    end
  
	    @pedigree = @full_pedigree
	  end
    end
	
    def authenticate_me(com)
      com.key = 'WCQY-7J1Q-GKVV-7DNM-SQ5M-9Q5H-JX3H-CMJK'
	  com.identity_v1.authenticate :username => current_user.fs_username, :password => current_user.fs_password
    end

	
	
	
end