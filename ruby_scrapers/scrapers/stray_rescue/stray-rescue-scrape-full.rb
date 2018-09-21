#!/usr/bin/env ruby
#stray-rescue-srape-full
require 'nokogiri'
require 'open-uri'
require 'mongoid'

require '../../models/pet.rb'
require '../../models/shelter.rb'
require './utils.rb'

include StrayRescueUtils
Mongoid.load!("../../config/mongoid.yml", :development)

# this is the main url of pets to be adopted, create Nokogiri Document
base_url = "https://www.strayrescue.org/animals-for-adoption"
doc = Nokogiri::HTML(open(base_url), nil, 'UTF-8')

puts "Stray Rescue of St Louis Scraper-Full"

shelter_document = get_or_create_shelter_document
puts "current pet count: #{ shelter_document.pets.count}"

# creates Array of all the individual pages listing pets to be adopted
paginated_urls = get_paginated_urls(doc)
puts "Total page numbers: #{paginated_urls.count}"

# iterates over each pet listing url, creates Nokogiri Document
# iterate over created Array of all pet urls found on the listing page 
# query MongoDB for existance of pet profile url
# create Nokogiri Document of pet profile url to gather pet information
# gather unique pet information from created Hash
# if Hash is nil, skips to next pet profile url
# create Pet Document from Hash, saves Pet Document to Shelter Document
paginated_urls.map do |paginated_url|
  puts "sleeping 10 on paginated page #{paginated_url}"
  sleep 10
  paginated_doc = Nokogiri::HTML(open(paginated_url), nil, 'UTF-8')
  pet_urls = unadopted_pet_urls_from_doc(paginated_doc)

  pet_urls.each do |pet_url|
    next if pet_url == "https://www.strayrescue.org/cache"
    if shelter_document.pets.where(profile_url: pet_url).any?
      puts "pre-existing pet encountered: \"#{pet_url}\""
      next
    end 
    sleep 10
    puts pet_url.inspect
    pet_doc = Nokogiri::HTML(open(pet_url), nil, 'UTF-8')
    pet_hash = create_pet_info_hash_from_doc(pet_doc)
    pet_hash[:profile_url] = pet_url
    puts pet_hash
    pet_document = create_pet_document_if_new(pet_hash)
    next if pet_document.nil?
    shelter_document.pets << pet_document
    shelter_document.save
    puts "#{pet_document.name} was added!!!!!!"
  end 
end
puts "updated pet count: #{shelter_document.pets.count}"
