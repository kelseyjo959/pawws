#!/usr/bin/env ruby
#stray-rescue-srape-lite
require 'nokogiri'
require 'open-uri'
require 'mongoid'
require '../../models/pet.rb'
require '../../models/shelter.rb'
require './utils.rb'

include StrayRescueUtils
Mongoid.load!("../../config/mongoid.yml", :development)

# main url of pets to be adopted, create Nokogiri Document
base_url = "https://www.strayrescue.org/animals-for-adoption"
doc = Nokogiri::HTML(open(base_url), nil, 'UTF-8')

puts "Stray Rescue of St Louis Scraper-Lite"

shelter_document = get_or_create_shelter_document

# create Array of all the individual pages listing pets to be adopted
paginated_urls = get_paginated_urls(doc)
puts "Total page number: #{paginated_urls.count}"

# iterates over each paginated_url
# creates a Nokogiri Document of the paginated_url, collects each unique pet_profile_url
# iterates over each unique pet_profile_url
# logs if a pre-existing pet is found in the DB and goes to next pet_profile_url
# if new pet found, creates pet_hash, saves as Pet Document, saves Pet Document to DB
# logs the pet added to DB
# if a pre-existing pet is found on paginated_url, the script will break 
# after it processes the last pet found on paginated_url 
# maybe break conditional should be nested inside the pet_urls.each method?
# so that it breaks right away without waiting to finish on the paginated_url?
pre_existing_pet = false
paginated_urls.map do |paginated_url|
  break if pre_existing_pet
  puts "sleeping 10 on #{paginated_url}"
  sleep 10
  paginated_doc = Nokogiri::HTML(open(paginated_url), nil, 'UTF-8')
  pet_urls = unadopted_pet_urls_from_doc(paginated_doc)

  pet_urls.each do |pet_url|
    if shelter_document.pets.where(profile_url: pet_url).any?
      pre_existing_pet = true
      puts "pre-existing pet encountered: \"#{pet_url}\""
      next
    end 
    sleep 10
    pet_doc = Nokogiri::HTML(open(pet_url), nil, 'UTF-8')
    pet_hash = create_pet_info_hash_from_doc(pet_doc)
    pet_hash[:profile_url] = pet_url
    pet_document = create_pet_document_if_new(pet_hash)
    next if pet_document.nil?
    shelter_document.pets << pet_document
    shelter_document.save
    puts "#{pet_document.name} was added!!!!!!" 
  end 
end

