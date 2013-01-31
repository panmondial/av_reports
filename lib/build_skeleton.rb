class BuildSkeleton < Struct.new(:my_pedigree, :com)

  def perform
    my_pedigree.continue_ids.each_slice(2) do |ids|
	  pedigrees = com.familytree_v2.pedigree ids
	  pedigrees.each do |ped|
	    my_pedigree.injest ped
	  end
    end
    
	Rails.cache.write("build_skeleton_cache", pedigree)
	puts "skeleton background job done"
  end  
  
end
