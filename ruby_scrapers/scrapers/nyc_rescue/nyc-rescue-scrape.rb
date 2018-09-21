#!/usr/bin/env ruby
#######nyc-scraper########
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
shelter_document = get_or_create_shelter_document

puts "NYC Shelter Buddy Scraper"
puts "current pet count: #{shelter_document.pets.count}"
# loop over requested url, create Nokogiri Document of requested url to iterate over
loop do
  puts "requested_url: #{requested_url}"
  doc = Nokogiri::HTML(open(requested_url), nil, 'UTF-8')
    
  current_url = current_url_from_doc(doc) 
  break unless current_url == requested_url
  # wont break unless the urls are different
  # scraping section
  pet_urls = pet_urls_from_doc(doc)
  # logs how many pets to be found on requested url
  puts "#{pet_urls.count} pets found"
  
  # iterate over each pet profile url 
  # query DB for pet profile url
  # create Nokogiri Document from pet profile url
  # create Hash for Pet Document for MongoDB
  pet_urls.map do |pet_url|
    if shelter_document.pets.where(profile_url: pet_url).any?
      puts "pre-existing pet encountered!!!!!!!!"
      puts "#{pet_url}"
      next
    end
    puts "sleeping 8"
    sleep 8
    pet_doc = Nokogiri::HTML(open(pet_url), nil, 'UTF-8')
    pet_hash = create_pet_info_hash_from_doc(pet_doc)
    next if pet_hash.nil?
 
    pet_hash[:profile_url] = pet_url
    puts pet_hash
    pet_document = create_pet_document_if_new(pet_hash)
    next if pet_document.nil?
    shelter_document.pets << pet_document
    shelter_document.save
    puts "!!!!!!!!#{pet_document.name} was added!!!!"
  end
  requested_url = increment_url(requested_url)
  puts "Iterated over a page, sleeping 8 then iterating over next"
  sleep 8 
  puts "#########################################################"
  sleep 8 
end
puts "updated pet count: #{shelter_document.pets.count}"
