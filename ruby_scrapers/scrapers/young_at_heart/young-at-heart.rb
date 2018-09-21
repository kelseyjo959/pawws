#!/usr/bin/env ruby
require 'nokogiri'
require 'open-uri'
require 'mongoid'
require '../../models/pet.rb'
require '../../models/shelter.rb'
require './utils.rb'


# load MongoDB config
include YoungAtHeartUtils
Mongoid.load!("../../config/mongoid.yml", :development)

# instantiate urls to iterate over and create Nokogiri Documents
base_dog_url = "http://www.adoptaseniorpet.com/adopt-a-pet/adopt-a-dog"
base_cat_url = "http://www.adoptaseniorpet.com/adopt-a-pet/adopt-a-cat"
base_courtesy_url = "http://www.adoptaseniorpet.com/adopt-a-pet/courtesy-listings"
cat_doc = Nokogiri::HTML(open(base_cat_url), nil, 'UTF-8')
dog_doc = Nokogiri::HTML(open(base_dog_url), nil, 'UTF-8')
courtesy_doc = Nokogiri::HTML(open(base_courtesy_url), nil, 'UTF-8')


shelter_document = get_or_create_shelter_document

# create one large array after iterating over each url to create each unique pet profile url
pet_urls = dog_urls_from_doc(dog_doc) + cat_urls_from_doc(cat_doc) + courtesy_urls_from_doc(courtesy_doc)
puts "Young At Heart Scraper"

puts "current pet count: #{shelter_document.pets.count}"

# iterates over each url, creates Nokogiri Document
# creates new Hash using function from utils.rb
# adds the profile url to the Hash
# creates Pet Document
# if the Document == nil for any reason, skip to next url
# saves the Pet Document to the Shelter Document
pet_urls.each do |pet_url|
  if shelter_document.pets.where(profile_url: pet_url).any?
    puts "pre-existing pet encountered!!!!"
    puts "#{pet_url}"
    next
  end
  doc = Nokogiri::HTML(open(pet_url), nil, 'UTF-8')
  pet_hash = pet_details_from_doc(doc)
  pet_hash[:profile_url] = pet_url
  pet_document = create_pet_document_if_new(pet_hash)
  next if pet_document.nil?
  shelter_document.pets << pet_document
  shelter_document.save
  puts "!!!!!!!!#{pet_document.name} was added to DB!!!!"
  puts pet_hash
  puts "#############sleeping 8################"
  sleep 8
end

puts "updated pet count: #{shelter_document.pets.count}"

