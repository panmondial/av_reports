class BuildDetail

  def initialize(root_person, current_user_id, session_id)
    @root_person = root_person
    @current_user_id = current_user_id
	@session_id = session_id
  end

  def enqueue(job)
    track_progress(1)
  end

  def perform
    # 1. Connect with the FamilySearch API and pull in a 4-generation pedigree for the
    # specified root person (:me is default for logged-in user)
    my_pedigree
    puts "1st part done!"

    # 2. Build basic pedigree, with no detail other than name, person identifier, gender, and parent ids
    ped_basic
    puts "2nd part done!"

    # 3. Add detail information to the pedigree skeleton by passing list of person identifiers
    # to FamilySearch API, and query person detail (with optional parameters)
    create_full_pedigree
    puts "Whole background job done!"
  end

  def error(job, exception)
    Rails.cache.write("job_errors_#{@current_user_id}", exception, :expires_in => 15.minutes)
  end
  
  
  private

  def track_progress(percent_complete)
    Rails.cache.write("percent_complete_#{@current_user_id}", percent_complete)
  end

  def subdomain
    @subdomain ||= Rails.env.production? ? 'sandbox' : 'sandbox'
  end

  def communicator
    @communicator ||= FsCommunicator.new(
      :domain => "https://#{subdomain}.familysearch.org",
      :handle_throttling => true,
      :session => @session_id
    )
  end

  def my_pedigree
	@my_pedigree ||= communicator.familytree_v2.pedigree(@root_person)
  end

  def ped_basic
    Rails.cache.fetch("ped_basic_cache_#{@current_user_id}_#{@root_person}", :expires_in => 4.hours, :compress => true) do
      my_pedigree.continue_ids.each_slice(2) do |ids|
        communicator.familytree_v2.pedigree(ids).each do |ped|
          my_pedigree.injest(ped)
        end
      end

      my_pedigree
    end
  end

  def create_full_pedigree
    full_pedigree = Org::Familysearch::Ws::Familytree::V2::Schema::Pedigree.new

    i = 0
    total_person_count = ped_basic.person_ids.length
    progress_count = 0
    percent_complete = 0

    persons = communicator.familytree_v2.person(ped_basic.person_ids, :parents => 'all', :events => 'standard', :names => 'summary', :families => 'summary') do |people|
      i += 1
      progress_count += people.size
      percent_complete = ((progress_count.to_f / total_person_count.to_f) * 100).to_i

      puts "#{progress_count} of #{total_person_count} fetched (#{percent_complete}%)"
      track_progress(percent_complete) if percent_complete == 100 || i % 2 == 0
    end

    persons.each do |person|
      full_pedigree << person
    end

    Rails.cache.fetch("full_pedigree_cache_#{@current_user_id}_#{@root_person}", :expires_in => 4.hours, :compress => true) do
	  full_pedigree
	end
	
	Rails.cache.write("result_root_person_name_#{@current_user_id}", full_pedigree.root.full_name, :expires_in => 4.hours)
	Rails.cache.write("result_root_person_id_#{@current_user_id}", full_pedigree.root.id, :expires_in => 4.hours)
  end

end
