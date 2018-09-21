#!/usr/bin/env ruby
#######nyc-full########
require 'nokogiri'
require 'open-uri'
require 'mongoid'
require '../../models/pet.rb'
require '../../models/shelter.rb'
require './utils.rb'

include NYCShelterUtils
Mongoid.load!("../../config/mongoid.yml", :development)

# initial search page url to begin iteration, create Nokogiri Document
base_search_url = "http://nycaccpets.shelterbuddy.com/search/searchResults.asp?advanced=0&searchType=4&animalType=2%2C15%2C3%2C16%2C15%2C16%2C86&datelostfoundmonth=11&datelostfoundday=25&datelostfoundyear=2017&submitbtn=Find+Animals&pagesize=15&task=view&searchTypeId=4&tpage=1"
base_doc = Nokogiri::HTML(open(base_search_url), nil, 'UTF-8')

shelter_document = get_or_create_shelter_document

# Array 
paginated_pages = get_paginated_pages(base_doc)
count = paginated_pages.count
puts "total page count:  #{count}"

paginated_pages.map do |paginated_url|
  puts "sleeping 8 on #{paginated_url}"
  sleep 8 
  paginated_doc = Nokogiri::HTML(open(paginated_url), nil, 'UTF-8')
  pet_urls = pet_urls_from_doc(paginated_doc)
  puts "#{pet_urls.count} pets found"

  pet_urls.each do |pet_url|
    if shelter_document.pets.where(profile_url: pet_url).any?
      puts "pre-existing pet encountered!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      next
    end
    sleep 8
    pet_doc = Nokogiri::HTML(open(pet_url), nil, 'UTF-8')
    pet_hash = create_pet_info_hash_from_doc(pet_doc)
    next if pet_hash.nil?

    pet_hash[:profile_url] = pet_url
    pet_document = create_pet_document_if_new(pet_hash) 
    next if pet_document.nil?
    shelter_document.pets << pet_document
    shelter_document.save
    puts "!!!!!!#{pet_document.name} was added!!!"
    puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  end
end


