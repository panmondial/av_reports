class BuildDetail < Struct.new(:my_pedigree, :FamilyTreeV2)

  def perform
    @pedigree = my_pedigree
    @full_pedigree = FamilyTreeV2::Pedigree.new
    total_person_count = @pedigree.person_ids.length
  
    progress_count = 0
    @persons = @com.familytree_v2.person @pedigree.person_ids, :parents => 'all', :events=> 'standard', :names=> 'summary', :families=> 'summary' do |persons|
      progress_count += persons.size
      Delayed::Job.current.update_attribute :progress, (progress_count/total_person_count)
    end
  
    @persons.each do |person|
      @full_pedigree << person
    end
  
    @pedigree = @full_pedigree
  end	
end
