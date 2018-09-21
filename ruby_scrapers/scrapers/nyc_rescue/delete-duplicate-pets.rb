Pet.each do |pet|
  occurances = Pet.where(profile_url: pet.profile_url).count
  next unless occurances > 1
  puts " #{occurances} occurances of #{pet.name}"
end
