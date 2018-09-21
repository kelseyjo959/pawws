#!/usr/bin/env ruby
#stray-rescue-removal
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

puts "Stray Resue of St Louis Adopted Pet Removal"

# creates Array of all the individual pages listing pets to be adopted
paginated_urls = get_paginated_urls(doc)
puts "Total number of urls:  #{paginated_urls.count}"

 
shelter = Shelter.where(name: "Stray Rescue of St Louis").first
db_pet_profile_urls = shelter.pets.map {|pet| pet.profile_url}
puts "current pet count: #{shelter.pets.count}"


all_pet_urls_on_website = []

# iterates over each pet listing url, creates Nokogiri Document
# function called to return all adopted pet profile urls
# finds the adopted pet profile url in the MongoDB
# removes the adopted pet from MongoDB
#paginated_urls.map do |paginated_url|
#  puts "sleeping 10 on #{paginated_url}"
#  sleep 10
#  paginated_doc = Nokogiri::HTML(open(paginated_url), nil, 'UTF-8')
#  adopted_pet_urls_from_doc(paginated_doc).map do |adopted_pet_profile_url|
#    adopted_pet = shelter.pets.where(profile_url: adopted_pet_profile_url).first
#    next unless adopted_pet
#    puts "#{adopted_pet.name} was adopted, removing from DB"
#    adopted_pet.delete
#  end
#end
#puts "Removed pet cards that said 'adopted'"
#puts "checking if any old content exists"
paginated_urls.map do |paginated_url|
  puts "sleeping 10 on #{paginated_url}"
  sleep 10
  paginated_doc = Nokogiri::HTML(open(paginated_url), nil, 'UTF-8')
  pet_urls = pet_urls_from_doc(paginated_doc)
  all_pet_urls_on_website.concat(pet_urls)
end
puts "pets on website: #{all_pet_urls_on_website.count}"
pets_no_longer_on_webpage = db_pet_profile_urls - all_pet_urls_on_website
puts "number of old data that needs to be removed from DB: #{pets_no_longer_on_webpage.count}"
pets_no_longer_on_webpage.map do |pet_no_longer_on_webpage|
  adopted_pet = shelter.pets.where(profile_url: pet_no_longer_on_webpage).first
  puts "#{adopted_pet.name} was adopted, removing from DB"
  adopted_pet.delete
end

puts "updated pet count: #{shelter.pets.count}"
