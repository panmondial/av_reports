class BuildDetail < Struct.new(:root_person, :id)

FamilyTreeV2 = Org::Familysearch::Ws::Familytree::V2::Schema

  def perform
    
	# 1. Connect with the FamilySearch API and pull in a 4-generation pedigree for the 
	# specified root person (:me is default for logged-in user)
	subdomain = Rails.env.production? ? 'sandbox' : 'sandbox'
	
	com = FsCommunicator.new(
      :domain => "https://#{subdomain}.familysearch.org",
	  :handle_throttling => true,
	  :session => id
    )
	
	my_pedigree = com.familytree_v2.pedigree root_person


	# 2. Build basic pedigree, with no detail other than name, person identifier, gender, and parent ids
	ped_basic = Rails.cache.read("ped_basic_cache_#{id}")

	if ped_basic.nil?
      my_pedigree.continue_ids.each_slice(2) do |ids|
	    pedigrees = com.familytree_v2.pedigree ids
	    pedigrees.each do |ped|
	      my_pedigree.injest ped
	    end
      end
	  ped_basic = my_pedigree
	  Rails.cache.write("ped_basic_cache_#{id}", ped_basic, :expires_in => 4.hours, :compress => true)
	else
	  ped_basic
	end
    
    puts "2nd part done!"
    
	
	# 3. Add detail information to the pedigree skeleton by passing list of person identifiers 
    # to FamilySearch API, and query person detail (with optional parameters)
	full_pedigree = FamilyTreeV2::Pedigree.new
	total_person_count = ped_basic.person_ids.length
    progress_count = 0

    persons = com.familytree_v2.person ped_basic.person_ids, :parents => 'all', :events=> 'standard', :names=> 'summary', :families=> 'summary' do |people|
      progress_count += people.size
      #Delayed::Job.current.update_attribute :progress, (progress_count/total_person_count)
    end
	
	persons.each do |person|
      full_pedigree << person
    end

	Rails.cache.write("full_pedigree_cache_#{id}", full_pedigree, :expires_in => 4.hours, :compress => true)
	puts "Whole background job done!"
  end  
  
end
  