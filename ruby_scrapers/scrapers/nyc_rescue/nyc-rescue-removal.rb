#!/usr/bin/env ruby
#nyc-rescue-removal
require 'nokogiri'
require 'open-uri'
require 'mongoid'
require '../../models/pet.rb'
require '../../models/shelter.rb'
require './utils.rb'

include NYCShelterUtils
Mongoid.load!("../../config/mongoid.yml", :development)

# initial search page url
requested_url = "http://nycaccpets.shelterbuddy.com/search/searchResults.asp?advanced=0&searchType=4&animalType=2%2C15%2C3%2C16%2C15%2C16%2C86&datelostfoundmonth=11&datelostfoundday=25&datelostfoundyear=2017&submitbtn=Find+Animals&pagesize=15&task=view&searchTypeId=4&tpage=1"

puts "NYC Shelter Buddy Adopted Pet Removal"

# query MongoDB for all pet profile urls, add to Array, log how many unique pets are found
shelter = Shelter.where(name: "NYC Shelter Buddy").first
db_pet_profile_urls = shelter.pets.map {|pet| pet.profile_url}
db_pet_profile_urls.uniq
puts "current pet count: #{db_pet_profile_urls.count}"

all_pet_urls_from_webpage = []

# loop over requested url, create Nokogiri Document of requested url to iterate over
# collect pet profile urls from requested urls
# add collected pet profile urls to 'all_pet_urls_from_webpage' Array
# increment the page number of requested url to iterate over next page
# sleep 8 on server request
loop do
  puts "requested_url: #{requested_url}"
  doc = Nokogiri::HTML(open(requested_url), nil, 'UTF-8')

  current_url = current_url_from_doc(doc)
  break unless current_url == requested_url
  # wont break unless the urls are different

  pet_urls = pet_urls_from_doc(doc)
  all_pet_urls_from_webpage.concat(pet_urls) 

  requested_url = increment_url(requested_url)
  puts "Iterated over a page, sleeping 8 then iterating over next"
  sleep 8  
  puts "#########################################################"
end

# if pet_profile_url from DB is not found in the Array of website pet profile urls
# need to remove the pet profile url from DB
# create new Array from the difference of DB urls and webpage urls
puts "#{all_pet_urls_from_webpage.count} = number of pets hosted on website"
adopted_pet_urls = db_pet_profile_urls - all_pet_urls_from_webpage
puts "#{adopted_pet_urls.count} = number of pets that were adopted"

# iterate over each adopted pet url
# variable 'adopted_pet' is Pet Document that matches the query of adopted pet profile url
# logs the name of adopted pet to be removed from DB 
# logs the removal of pet profile url and Pet Document from DB
# removes Pet Document from DB

adopted_pet_urls.map do |adopted_pet_url|
  puts "################################################"
  puts adopted_pet_url
  adopted_pet = shelter.pets.where(profile_url: adopted_pet_url).first
  if adopted_pet.nil?
    puts "#{adopted_pet_url} could not be found for removal"
    next 
  end
  puts "#{adopted_pet.name} was adopted!!!!!!!!"
  puts "Removing #{adopted_pet_url} from database"
  adopted_pet.delete
end
puts "updated pet count: #{shelter.pets.count}"
