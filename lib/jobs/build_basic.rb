class BuildBasic < Struct.new(:id)

  def perform
    # 1. Connect with the FamilySearch API and pull in a 4-generation pedigree for the 
	# specified root person (:me is default for logged-in user)
	subdomain = Rails.env.production? ? 'sandbox' : 'sandbox'
	
	com = FsCommunicator.new(
      :domain => "https://#{subdomain}.familysearch.org",
	  :handle_throttling => true,
	  :session => id
    )
	
	my_pedigree = com.familytree_v2.pedigree :me

	# 2. Build basic pedigree, with no detail other than name, person identifier, gender, and parent ids
    my_pedigree.continue_ids.each_slice(2) do |ids|
	  pedigrees = com.familytree_v2.pedigree ids
	  pedigrees.each do |ped|
	    my_pedigree.injest ped
	  end
    end
    
    Rails.cache.write("ped_basic_cache_#{id}", my_pedigree, :expires_in => 4.hours, :compress => true)
	puts "basic pedigree background job done"
	
  end  
  
end
