require 'mongoid'
require './models/pet.rb'
require './models/shelter.rb'
require 'nokogiri'
require 'open-uri'
Mongoid.load!("./config/mongoid.yml", :development)

