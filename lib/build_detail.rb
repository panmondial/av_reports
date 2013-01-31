class BuildDetail < Struct.new(:pedigree, :com, :full_pedigree)

  def perform
    total_person_count = pedigree.person_ids.length
    progress_count = 0

    persons = com.familytree_v2.person pedigree.person_ids, :parents => 'all', :events=> 'standard', :names=> 'summary', :families=> 'summary' do |persons|
      progress_count += persons.size
      #Delayed::Job.current.update_attribute :progress, (progress_count/total_person_count)
    end
	
	persons.each do |person|
      full_pedigree << person
    end

    pedigree = full_pedigree

	Rails.cache.write("build_detail_cache", pedigree)
	puts "background job done"
  end  
  
end
  