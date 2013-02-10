require 'csv'

class ReportsController < ApplicationController
  before_filter :signed_in_user, except: :index
  helper_method :build_pedigree, :pedigree_built?
    
  def end_of_line
	@filter_criteria = lambda { |ped| (ped.father_id.nil? || ped.mother_id.nil?) }
	@report_title = __method__.to_s.titleize + " Report"
	@report_description = "This report shows direct-line ancestors at the end of each branch of the family tree."
	respond_to do |format|
	  format.html {render '_report_detail', :layouts => 'reports', :locals => {:@filter_criteria => @filter_criteria } }
	  format.csv do
		build_csv(@pedigree)
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
		build_csv(@pedigree)
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
        build_csv(@pedigree)
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
		build_csv(@pedigree)
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
		build_csv(@pedigree)
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
		build_csv(@pedigree)
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
	    build_csv(@pedigree)
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
	    build_csv(@pedigree)
		send_data @csv_array, filename: "#{__method__}.csv"
	  end
	end
  end

  def run_reports
    if pedigree_built?
      @type = params[:type]
          case @type
        when 'end_of_line' then end_of_line
            when 'direct_line_all' then direct_line_all
            when 'missing_birth_date' then missing_birth_date
            when 'missing_birth_place' then missing_birth_place
        when 'incomplete_birth_date' then incomplete_birth_date
        when 'missing_death_date' then missing_death_date
        when 'missing_death_place' then missing_death_place
        when 'incomplete_death_date' then incomplete_death_date
        else end_of_line
      end
    else
      flash[:error] = 'You must load pedigree data before running reports.'
      redirect_to reports_path
    end
  end

  def build_detail_ped
    begin
      Delayed::Job.enqueue(BuildDetail.new(params[:root_person], session[:api_session_id]))
      render :json => { :message => 'Accepted' }, :status => :accepted
    rescue Exception => error
      if request.format.json?
        logger.error error.message
        logger.error error.backtrace.join("\n")
        render :json => { :message => 'Bad Request' }, :status => :bad_request
      else
        raise error
      end
    end
  end

  def progress
    render :json => { :percent_complete => check_progress }, :status => :ok
  end

  # Helper methods

  def build_pedigree
    @pedigree = Rails.cache.read("full_pedigree_cache_#{session[:api_session_id]}")
  end

  def pedigree_built?
    Rails.cache.exist?("full_pedigree_cache_#{session[:api_session_id]}")
  end

  private

  def build_csv(data)
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

  def check_progress
    Rails.cache.read("percent_complete_#{session[:api_session_id]}") || 1
  end
  
end
