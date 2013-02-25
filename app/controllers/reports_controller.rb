require 'csv'
require 'iconv'

class ReportsController < ApplicationController
  before_filter :signed_in_user, except: :index
  before_filter :sign_in_notice
  helper_method :build_pedigree, :pedigree_built?
    
  def end_of_line
	@filter_criteria = lambda { |ped| (ped.father_id.nil? || ped.mother_id.nil?) }
	@report_title = __method__.to_s.titleize + " Report"
	@report_description = "This report shows direct-line ancestors at the end of each branch of the family tree."
	respond_to do |format|
	  format.html {render '_report_detail', :layouts => 'reports', :locals => {:@filter_criteria => @filter_criteria } }
	  format.csv do
		build_csv
		send_data Iconv.conv('iso-8859-1//IGNORE', 'utf-8', @csv_array), \
		:type => 'text/csv; charset=iso-8859-1; header=present', filename: "#{__method__}.csv"
      end
	  format.xls do
	    build_excel("#{__method__}")
		send_data @spreadsheet.string, filename: "#{__method__}.xls", :type =>  "application/vnd.ms-excel"
	  end
	end
  end

  def direct_line_ancestors
	@filter_criteria = lambda { |ped| ped.id }
	@report_title = __method__.to_s.titleize + " Report"
	@report_description = "This report shows all ancestors in a direct-line relationship (ex: self, father, mother, grandfather, grandmother, etc.)"
	respond_to do |format|
	  format.html {render '_report_detail', :layouts => 'reports', :locals => {:@filter_criteria => @filter_criteria } }
	  format.csv do
		build_csv
		send_data Iconv.conv('iso-8859-1//IGNORE', 'utf-8', @csv_array), \
		:type => 'text/csv; charset=iso-8859-1; header=present', filename: "#{__method__}.csv"
      end
	  format.xls do
	    build_excel("#{__method__}")
		send_data @spreadsheet.string, filename: "#{__method__}.xls", :type =>  "application/vnd.ms-excel"
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
		send_data Iconv.conv('iso-8859-1//IGNORE', 'utf-8', @csv_array), \
		:type => 'text/csv; charset=iso-8859-1; header=present', filename: "#{__method__}.csv"
      end
	  format.xls do
	    build_excel("#{__method__}")
		send_data @spreadsheet.string, filename: "#{__method__}.xls", :type =>  "application/vnd.ms-excel"
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
		send_data Iconv.conv('iso-8859-1//IGNORE', 'utf-8', @csv_array), \
		:type => 'text/csv; charset=iso-8859-1; header=present', filename: "#{__method__}.csv"
      end
	  format.xls do
	    build_excel("#{__method__}")
		send_data @spreadsheet.string, filename: "#{__method__}.xls", :type =>  "application/vnd.ms-excel"
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
		send_data Iconv.conv('iso-8859-1//IGNORE', 'utf-8', @csv_array), \
		:type => 'text/csv; charset=iso-8859-1; header=present', filename: "#{__method__}.csv"
      end
	  format.xls do
	    build_excel("#{__method__}")
		send_data @spreadsheet.string, filename: "#{__method__}.xls", :type =>  "application/vnd.ms-excel"
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
		send_data Iconv.conv('iso-8859-1//IGNORE', 'utf-8', @csv_array), \
		:type => 'text/csv; charset=iso-8859-1; header=present', filename: "#{__method__}.csv"
      end
	  format.xls do
	    build_excel("#{__method__}")
		send_data @spreadsheet.string, filename: "#{__method__}.xls", :type =>  "application/vnd.ms-excel"
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
		send_data Iconv.conv('iso-8859-1//IGNORE', 'utf-8', @csv_array), \
		:type => 'text/csv; charset=iso-8859-1; header=present', filename: "#{__method__}.csv"
      end
	  format.xls do
	    build_excel("#{__method__}")
		send_data @spreadsheet.string, filename: "#{__method__}.xls", :type =>  "application/vnd.ms-excel"
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
		send_data Iconv.conv('iso-8859-1//IGNORE', 'utf-8', @csv_array), \
		:type => 'text/csv; charset=iso-8859-1; header=present', filename: "#{__method__}.csv"
      end
	  format.xls do
	    build_excel("#{__method__}")
		send_data @spreadsheet.string, filename: "#{__method__}.xls", :type =>  "application/vnd.ms-excel"
	  end
	end
  end

  
  
# Data Generation Methods 
  
  def run_reports
	begin
	  @type = params[:type]
	  @root_person = params[:root_person]
	  
	  get_person = communicator.familytree_v2.person(@root_person)
	  
	  Rails.cache.write("root_person_cache_#{current_user.id}", @root_person, :expires_in => 4.hours)
	  Rails.cache.write("report_type_cache_#{current_user.id}", @type, :expires_in => 4.hours)
	  Rails.cache.write("result_root_person_name_#{@current_user.id}_#{@root_person}", get_person.full_name, :expires_in => 4.hours)
	  Rails.cache.write("result_root_person_id_#{@current_user.id}_#{@root_person}", get_person.id, :expires_in => 4.hours)
	
      if pedigree_built?
	    case @type
          when 'direct_line_ancestors' then direct_line_ancestors
          when 'end_of_line' then end_of_line
          when 'missing_birth_date' then missing_birth_date
          when 'missing_birth_place' then missing_birth_place
          when 'incomplete_birth_date' then incomplete_birth_date
          when 'missing_death_date' then missing_death_date
          when 'missing_death_place' then missing_death_place
          when 'incomplete_death_date' then incomplete_death_date
          else end_of_line
        end
      else
	    build_detail_ped
	    flash[:alert] = "Your report data is loading. Please wait until loading is complete, then select a report."
        redirect_to reports_path
      end
	rescue RubyFsStack::ServiceUnavailable => error
      if request.format.json?
	    logger.error error.message
        logger.error error.backtrace.join("\n")
        render :json => { :message => "2The FamilySearch service is currently unavailable. Please try again." }, :status => :bad_request
	  else
	    flash[:error] = "2The FamilySearch service is currently unavailable. Please try again."	
	    render :index
	  end

	rescue RubyFsStack::Unauthorized => error # works to catch error if session expired from FamilySearch
      if request.format.json?
	    logger.error error.message
        logger.error error.backtrace.join("\n")
        render :json => { :message => "Your FamilySearch session has timed out. Please sign out of Arbor Vitae, and sign in again to reset your FamilySearch session." }, :status => :bad_request
	  else
	    flash[:error] = "Your FamilySearch session has timed out. Please sign out of Arbor Vitae, and sign in again to reset your FamilySearch session."	
	    render :index
	  end
	  
	rescue RubyFsStack::NotFound => error # works when trying to "Load" data for invalid FS ID - for bookmarked person
      if request.format.json?
	    logger.error error.message
        logger.error error.backtrace.join("\n")
        render :json => { :message => "FamilySearch was unable to find Person ID: #{params[:root_person] || @root_person}. Please try again." }, :status => :bad_request
	  else
	    flash[:error] = "FamilySearch was unable to find Person ID: #{params[:root_person] || @root_person}. Please try again."
        render :index
	  end
    
	rescue Timeout::Error => error
      if request.format.json?
	    logger.error error.message
        logger.error error.backtrace.join("\n")
        render :json => { :message => "1Your FamilySearch server request has timed out. Please try again." }, :status => :bad_request
	  else
	    flash[:error] = "1Your FamilySearch server request has timed out. Please try again."	
	    render :index
	  end
	
	rescue Exception => error
      flash[:error] = "Exception: #{error.message} and this is ...Invalid report parameters. Please try again."
      render :index
    end
  end
	
  def build_detail_ped
	begin
	  r_person = params[:root_person] || @root_person
	  Rails.cache.delete("job_errors_#{@current_user.id}_#{r_person}")
	  communicator.familytree_v2.person(r_person)
	  
	  if r_person == "me"
		person_select = "me"
		other_person_id = nil
	  else
	    person_select = "other"
		other_person_id = r_person
	  end
	  
	  Rails.cache.write("root_person_cache_#{current_user.id}", r_person, :expires_in => 4.hours)
	  Rails.cache.write("person_select_cache_#{current_user.id}", person_select, :expires_in => 4.hours)
	  Rails.cache.write("other_person_id_cache_#{current_user.id}", other_person_id, :expires_in => 4.hours)
	  
	  if !pedigree_built?
	    Delayed::Job.enqueue(BuildDetail.new(r_person, current_user.id, session[:api_session_id], false))
      end
	  
	  if request.format.json?
	    render :json => { :message => 'Accepted' }, :status => :accepted
	  end
	rescue RubyFsStack::ServiceUnavailable => error
      if request.format.json?
	    logger.error error.message
        logger.error error.backtrace.join("\n")
        render :json => { :message => "2The FamilySearch service is currently unavailable. Please try again." }, :status => :bad_request
	  else
	    flash[:error] = "2The FamilySearch service is currently unavailable. Please try again."	
	    render :index
	  end

	  rescue RubyFsStack::Unauthorized => error # works to catch error if session expired from FamilySearch
      if request.format.json?
	    logger.error error.message
        logger.error error.backtrace.join("\n")
        render :json => { :message => "Your FamilySearch session has timed out. Please sign out of Arbor Vitae, and sign in again to reset your FamilySearch session." }, :status => :bad_request
	  else
	    flash[:error] = "Your FamilySearch session has timed out. Please sign out of Arbor Vitae, and sign in again to reset your FamilySearch session."	
	    render :index
	  end
	  
	rescue RubyFsStack::NotFound => error # works when trying to "Load" data for invalid FS ID
      if request.format.json?
	    logger.error error.message
        logger.error error.backtrace.join("\n")
        render :json => { :message => "FamilySearch was unable to find Person ID: #{params[:root_person] || @root_person}. Please try again." }, :status => :bad_request
	  else
	    flash[:error] = "FamilySearch was unable to find Person ID: #{params[:root_person] || @root_person}. Please try again."
        render :index
	  end
	rescue Timeout::Error => error
      if request.format.json?
	    logger.error error.message
        logger.error error.backtrace.join("\n")
        render :json => { :message => "1Your FamilySearch server request has timed out. Please try again." }, :status => :bad_request
	  else
	    flash[:error] = "1Your FamilySearch server request has timed out. Please try again."	
	    render :index
	  end
	
	rescue Exception => error
      if request.format.json?
        logger.error error.message
        logger.error error.backtrace.join("\n")
        render :json => { :message => "4Exception: #{error.message} and this is ...Invalid report parameters. Please try again." }, :status => :bad_request
      else
        flash[:alert] = "4Exception: #{error.message} and this is ...Invalid report parameters. Please try again."
        render :index
      end
    end
  end

  def clear_cache
    @root_person =  Rails.cache.read("root_person_cache_#{current_user.id}")
	Rails.cache.delete("full_pedigree_cache_#{current_user.id}_#{@root_person}")
    Rails.cache.delete("ped_basic_cache_#{current_user.id}_#{@root_person}")
    Rails.cache.delete("job_errors_#{current_user.id}_#{@root_person}")
    Rails.cache.delete("other_person_id_cache_#{current_user.id}")
    Rails.cache.delete("percent_complete_#{current_user.id}_#{@root_person}")
    Rails.cache.delete("person_select_cache_#{current_user.id}")
    Rails.cache.delete("report_type_cache_#{current_user.id}")
    Rails.cache.delete("result_root_person_id_#{current_user.id}_#{@root_person}")
    Rails.cache.delete("result_root_person_name_#{current_user.id}_#{@root_person}")
    Rails.cache.delete("root_person_cache_#{current_user.id}")
	
	respond_to do |format|
      format.html { redirect_to reports_path, :flash => { :success => "Data cleared successfully!" } }
      format.json{
        render :json => { :data_cleared => true }, :status => :ok
      }
    end	
  end

  def reload_data
    begin
	  reload_person = params[:root_person]
	  
	  Rails.cache.delete("job_errors_#{@current_user.id}_#{reload_person}")
      Rails.cache.delete("percent_complete_#{@current_user.id}_#{reload_person}")
      Rails.cache.delete("ped_basic_cache_#{@current_user.id}_#{reload_person}")
      Rails.cache.delete("full_pedigree_cache_#{@current_user.id}_#{reload_person}")
      Rails.cache.delete("result_root_person_name_#{@current_user.id}_#{reload_person}")
      Rails.cache.delete("result_root_person_id_#{@current_user.id}_#{reload_person}")	  
	  
	  Delayed::Job.enqueue(BuildDetail.new(reload_person, current_user.id, session[:api_session_id], true))
	
	  if request.format.json?
	    render :json => { :message => 'Accepted' }, :status => :accepted
	  end
	
    rescue RubyFsStack::ServiceUnavailable => error
      if request.format.json?
	    logger.error error.message
        logger.error error.backtrace.join("\n")
        render :json => { :message => "2The FamilySearch service is currently unavailable. Please try again." }, :status => :bad_request
	  else
	    flash[:error] = "2The FamilySearch service is currently unavailable. Please try again."	
	    render :index
	  end
	rescue RubyFsStack::Unauthorized => error # works to catch error if session expired from FamilySearch
      if request.format.json?
	    logger.error error.message
        logger.error error.backtrace.join("\n")
        render :json => { :message => "Your FamilySearch session has timed out. Please sign out of Arbor Vitae, and sign in again to reset your FamilySearch session." }, :status => :bad_request
	  else
	    flash[:error] = "Your FamilySearch session has timed out. Please sign out of Arbor Vitae, and sign in again to reset your FamilySearch session."	
	    render :index
	  end
	rescue RubyFsStack::NotFound => error # works when trying to "Load" data for invalid FS ID
      if request.format.json?
	    logger.error error.message
        logger.error error.backtrace.join("\n")
        render :json => { :message => "FamilySearch was unable to find Person ID: #{params[:root_person] || @root_person}. Please try again." }, :status => :bad_request
	  else
	    flash[:error] = "FamilySearch was unable to find Person ID: #{params[:root_person] || @root_person}. Please try again."
        render :index
	  end
	rescue Timeout::Error => error
      if request.format.json?
	    logger.error error.message
        logger.error error.backtrace.join("\n")
        render :json => { :message => "1Your FamilySearch server request has timed out. Please try again." }, :status => :bad_request
	  else
	    flash[:error] = "1Your FamilySearch server request has timed out. Please try again."	
	    render :index
	  end
	rescue Exception => error
      if request.format.json?
        logger.error error.message
        logger.error error.backtrace.join("\n")
        render :json => { :message => "4Exception: #{error.message} and this is ...Invalid report parameters. Please try again." }, :status => :bad_request
      else
        flash[:alert] = "4Exception: #{error.message} and this is ...Invalid report parameters. Please try again."
        render :index
      end
    end  
	  
  end 
  
  
  # Helper methods

  def build_pedigree
	@pedigree = Rails.cache.read("full_pedigree_cache_#{current_user.id}_#{@root_person}")
  end

  def pedigree_built?
	if signed_in?
	  @root_person = Rails.cache.read("root_person_cache_#{current_user.id}")
	  Rails.cache.exist?("full_pedigree_cache_#{current_user.id}_#{@root_person}")
	else
	  false
	end
  end
  
  def progress
    render :json => { :percent_complete => check_progress, :jerror => background_error }, :status => :ok
  end
  
  def orig_params
	orig_person_select = Rails.cache.read("person_select_cache_#{current_user.id}") || nil #if Rails.cache.exist?("person_select_cache_#{current_user.id}")
	orig_other_person_id = Rails.cache.read("other_person_id_cache_#{current_user.id}") || nil #if Rails.cache.exist?("other_person_id_cache_#{current_user.id}")
	orig_report_type = Rails.cache.read("report_type_cache_#{current_user.id}") || nil #if Rails.cache.exist?("report_type_cache_#{current_user.id}")
    orig_root_person = Rails.cache.read("root_person_cache_#{current_user.id}") || nil #if Rails.cache.exist?("root_person_cache_#{current_user.id}")

	respond_to do |format|
      format.html { redirect_to reports_path, :flash => { :success => "Successfully logged in!" } }
      format.json{
        if signed_in?
	      render :json => { :jperson_select => orig_person_select, :jother_person_id => orig_other_person_id, \
		  :j_root_person => orig_root_person, :jreport_type => orig_report_type, \
		  :jresult_person_name => result_root_person_name, :jresult_person_id => result_root_person_id, \
		  :percent_complete => check_progress, :jpedigree_built => pedigree_built? }, :status => :ok
	    end
      }
    end	
  end

  

  def build_csv
	@root_person = Rails.cache.read("root_person_cache_#{current_user.id}")
	pedigree = Rails.cache.read("full_pedigree_cache_#{current_user.id}_#{@root_person}")
	@csv_array = CSV.generate do |csv|
      csv << ['FamilySearch ID', 'First Name', 'Last Name', 'Gender', 'Birth Date', 'Birth Place', 'Death Date', 'Death Place']
      pedigree.persons.find_all(&@filter_criteria).each do |ped|
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
  
  def build_excel(method_name)
    book=Spreadsheet::Workbook.new
	  sheet1=book.create_worksheet :name=> method_name
	  sheet1[0,0]="FamilySearch ID"
	  sheet1[0,1]="First Name"
	  sheet1[0,2]="Last Name"
	  sheet1[0,3]="Gender"
	  sheet1[0,4]="Birth Date"
	  sheet1[0,5]="Birth Place"
	  sheet1[0,6]="Death Date"
	  sheet1[0,7]="Death Place"
	  sheet1.row(0).height = 18
	  format = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 12
	  sheet1.row(0).default_format = format
	  sheet1.column(0).width=20
	  sheet1.column(1).width=25
	  sheet1.column(2).width=25
	  sheet1.column(3).width=10
	  sheet1.column(4).width=20
	  sheet1.column(5).width=50
	  sheet1.column(6).width=20
	  sheet1.column(7).width=50

      nextrow = 1

	  @root_person = Rails.cache.read("root_person_cache_#{current_user.id}")
	  pedigree = Rails.cache.read("full_pedigree_cache_#{current_user.id}_#{@root_person}")
	  
      pedigree.persons.each do |pedxls|
	    next if (pedxls.full_name.nil?) or (pedxls.birth && pedxls.birth.date)
#		  sheet1[nextrow,0]=Spreadsheet::Link.new "https://sandbox.familysearch.org/en/action/hourglassiconicview?bookid=p." + pedxls.id + "&focus=p." + pedxls.id + "&svfs=1&sv=1"+ pedxls.id + "&focus=p." + pedxls.id + "&svfs=1&sv=1" + "?access_token=" + session[:api_session_id], pedxls.id
		  sheet1[nextrow,0]=Spreadsheet::Link.new "https://sandbox.familysearch.org/tree/#view=ancestor&person=" + pedxls.id + "?access_token=" + session[:api_session_id], pedxls.id
		  sheet1[nextrow,1]=pedxls.assertions.names[0].value.forms[0].pieces.select {|fn| fn.type=="Given"}.collect \
		    {|fn| fn.value.to_s}.join(" ") if pedxls.assertions && pedxls.assertions.names && pedxls.assertions.names[0].value \
			&& pedxls.assertions.names[0].value.forms[0] && pedxls.assertions.names[0].value.forms[0].pieces[0]
		  sheet1[nextrow,2]=((pedxls.assertions.names[0].value.forms[0].pieces.select {|fn| fn.type=="Family"}.collect \
		    {|fn| fn.value.to_s}.join(" ") if pedxls.assertions && pedxls.assertions.names && pedxls.assertions.names[0].value \
			&& pedxls.assertions.names[0].value.forms[0] && pedxls.assertions.names[0].value.forms[0].pieces[0]) + " " \
			  + (pedxls.assertions.names[0].value.forms[0].pieces.select {|fn| fn.type=="Suffix"}.collect \
			    {|fn| fn.value.to_s}.join(" ") if pedxls.assertions && pedxls.assertions.names && pedxls.assertions.names[0].value \
			    && pedxls.assertions.names[0].value.forms[0] && pedxls.assertions.names[0].value.forms[0].pieces[0])).strip
		  sheet1[nextrow,3]=pedxls.gender
		  sheet1[nextrow,4]=pedxls.birth.date.normalized if pedxls.birth && pedxls.birth.date && pedxls.birth.date.normalized
		  sheet1[nextrow,5]=pedxls.birth.place.normalized.value if pedxls.birth && pedxls.birth.place \
			&& pedxls.birth.place.normalized && pedxls.birth.place.normalized.value
		  sheet1[nextrow,6]=pedxls.death.date.normalized if pedxls.death && pedxls.death.date && pedxls.death.date.normalized	
		  sheet1[nextrow,7]=pedxls.death.place.normalized.value if pedxls.death && pedxls.death.place \
			&& pedxls.death.place.normalized && pedxls.death.place.normalized.value
          nextrow += 1
		  
		  @spreadsheet = StringIO.new
		  book.write @spreadsheet	  
      end
    end


	
  
  private
  
  def check_progress
    @root_person = Rails.cache.read("root_person_cache_#{current_user.id}")
	Rails.cache.read("percent_complete_#{current_user.id}_#{@root_person}")
  end
  
  def background_error
    if Rails.cache.exist?("job_errors_#{@current_user.id}_#{@root_person}")
	  Rails.cache.read("job_errors_#{current_user.id}_#{@root_person}").to_s
    end
  end
  
  def result_root_person_name
    if signed_in?
	  @root_person = Rails.cache.read("root_person_cache_#{current_user.id}")
	  if Rails.cache.exist?("result_root_person_name_#{current_user.id}_#{@root_person}")
        Rails.cache.read("result_root_person_name_#{current_user.id}_#{@root_person}")
	  end
	else
	  false
	end
  end
    
  def result_root_person_id
    if signed_in?
	  @root_person = Rails.cache.read("root_person_cache_#{current_user.id}")
	  if Rails.cache.exist?("result_root_person_id_#{current_user.id}_#{@root_person}")
        Rails.cache.read("result_root_person_id_#{current_user.id}_#{@root_person}")
	  end
	else
	  false
	end
  end
  
  def sign_in_notice
	unless signed_in?
	  flash[:error] = "Please sign in to use reports!"
	end
  end
  
  def subdomain
    @subdomain ||= Rails.env.production? ? 'sandbox' : 'sandbox'
  end

  def communicator
	@communicator ||= FsCommunicator.new(
      :domain => "https://#{subdomain}.familysearch.org",
      :handle_throttling => true,
      :session => session[:api_session_id]
    )
  end
  
end
