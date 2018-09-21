#!/usr/bin/env ruby
#########stl-404-checker#######
require 'nokogiri'
require 'open-uri'
require 'mongoid'
require '../../models/pet.rb'
require '../../models/shelter.rb'
require './utils.rb'
require 'net/http'

include StrayRescueUtils
Mongoid.load!("../../config/mongoid.yml", :development)

puts "stl 404 image checker"

shelter = Shelter.where(name: "Stray Rescue of St Louis").first

db_pet_img_urls = shelter.pets.map {|pet| pet.img_url}
puts "pets in db: #{db_pet_img_urls.count}"


db_pet_img_urls.map do |db_pet_img_url|
  uri = URI(db_pet_img_url)
  res = Net::HTTP.get_response(uri)
  #puts res.code
  response = res.code
  if response == "404"
    puts "url does not exist, pet needs to be dropped"
    unresolved_pet = shelter.pets.where(img_url: db_pet_img_url).first
    puts "#{unresolved_pet.name} was dropped"
    unresolved_pet.delete
  end
  sleep 8
end
