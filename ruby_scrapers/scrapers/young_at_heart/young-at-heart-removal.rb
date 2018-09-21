#!/usr/bin/env ruby
require 'nokogiri'
require 'open-uri'
require 'mongoid'
require '../../models/pet.rb'
require '../../models/shelter.rb'
require './utils.rb'

include YoungAtHeartUtils
Mongoid.load!("../../config/mongoid.yml", :development)

# calls up the 'Young At Heart' Shelter Document
shelter = Shelter.where(url:"http://www.adoptaseniorpet.com/adopt-a-pet").first


# collect page urls to iterate over and create Nokogiri Documents
base_cat_url = "http://www.adoptaseniorpet.com/adopt-a-pet/adopt-a-cat"
base_dog_url = "http://www.adoptaseniorpet.com/adopt-a-pet/adopt-a-dog"
base_courtesy_url = "http://www.adoptaseniorpet.com/adopt-a-pet/courtesy-listings"

cat_doc = Nokogiri::HTML(open(base_cat_url), nil, 'UTF-8')
dog_doc = Nokogiri::HTML(open(base_dog_url), nil, 'UTF-8')
courtesy_doc = Nokogiri::HTML(open(base_courtesy_url), nil, 'UTF-8')

# creates one large array after iterating over each url to create each unique pet profile url
site_profile_urls = dog_urls_from_doc(dog_doc) + cat_urls_from_doc(cat_doc) + courtesy_urls_from_doc(courtesy_doc)

# create array of pet profile urls found in the database for this Shelter Document
db_pet_profile_urls = shelter.pets.map {|pet| pet.profile_url}

# find the pet profiles that are no longer listed on the the website but still remain in the DB that need to be removed
adopted_pet_urls = db_pet_profile_urls - site_profile_urls
# [c, e] = [a, b, c, d, e, f] - [a, b, d, f]

puts "Young At Heart Adopted Pet Removal"
puts "current pet count: #{shelter.pets.count}"

# creates logging to screen to verify which pets are to be removed from the DB
adopted_pet_urls.map do |pet_profile_url|
  shelter.pets.where(profile_url: "#{pet_profile_url}").first.delete
  puts "removing #{pet_profile_url} from database"
end
puts "updated pet count: #{shelter.pets.count}"
