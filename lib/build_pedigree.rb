module BuildPedigree

require 'ruby-fs-stack'
require_relative './authenticate.rb'

@com = FsCommunicator.new :domain => 'https://sandbox.familysearch.org', :handle_throttling => true
FamilyTreeV2 = Org::Familysearch::Ws::Familytree::V2::Schema

  def self.build_pedigree
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

  #filter = Proc.new do |(ped.birth && ped.birth.date)| end
  
  # def self.run_reports 
    # birth_place = (ped.birth && ped.birth.date)
	
	# puts build_pedigree.person_ids
    # puts build_pedigree(@com).inspect
    # puts build_pedigree(@com).person_ids - THIS ONE WORKS!!!!!
    # puts build_pedigree(@com).persons.to_yaml
    # puts build_pedigree(@com).root.full_name - THIS ONE WORKS!!!!
    # THE FOLLOWING CODE SUCCESSFULLY OUTPUTS THE nFS ID, FULL NAME AND GENDER FOR EACH PERSON IN THE PEDIGREE
      # build_pedigree.persons.each do |ped|
        # next if yield(ped)
	      # puts ped.id
	      # puts ped.full_name
	      # puts ped.gender
	      # puts ped.father_id
	      # puts ped.mother_id
	      # puts ped.gender
	      # puts ped.assertions.names[0].value.forms[0].pieces.select {|fn| fn.type=="Family"}.collect {|fn| fn.value.to_s}.join(" ") \
  	        # if ped.assertions && ped.assertions.names && ped.assertions.names[0].value && ped.assertions.names[0].value.forms[0] \
	          # && ped.assertions.names[0].value.forms[0].pieces[0]
	      # puts ped.assertions.names[0].value.forms[0].pieces.select {|fn| fn.type=="Suffix"}.collect {|fn| fn.value.to_s}.join(" ") \
	        # if ped.assertions && ped.assertions.names && ped.assertions.names[0].value && ped.assertions.names[0].value.forms[0] \
	          # && ped.assertions.names[0].value.forms[0].pieces[0]
          # puts ped.assertions.names[0].value.forms[0].pieces.select {|fn| fn.type=="Given"}.collect {|fn| fn.value.to_s}.join(" ") \
	        # if ped.assertions && ped.assertions.names && ped.assertions.names[0].value && ped.assertions.names[0].value.forms[0] \
	          # && ped.assertions.names[0].value.forms[0].pieces[0]
	      # puts ped.birth.date.normalized if ped.birth && ped.birth.date && ped.birth.date.normalized
	      # puts ped.birth.place.normalized.value if ped.birth && ped.birth.place && ped.birth.place.normalized && ped.birth.place.normalized.value
	      # puts ped.death.date.normalized if ped.death && ped.death.date && ped.death.date.normalized	
	      # puts ped.death.place.normalized.value if ped.death && ped.death.place && ped.death.place.normalized && ped.death.place.normalized.value
	
        # end
      # end
  
  #run_reports { |ped| (ped.birth && ped.birth.date) }
  
  filter_criteria = lambda { |ped| (ped.birth && ped.birth.date) }
  
  build_pedigree.persons.find_all(&filter_criteria).each { |ped| p ped.id, ped.full_name }
  
  @pedigree.persons.each do |red|
    puts red.id
  end

  
  @people = @pedigree.persons.find_all(&@filter_criteria)
  
  @people.each do |x|
    puts x.id
  end  
end
