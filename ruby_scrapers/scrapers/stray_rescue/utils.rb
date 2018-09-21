#!/usr/bin/env ruby

module StrayRescueUtils
   # return: MongoDB shelter document
   # creates a new Shelter Document in the MongoDB with the two following parameters  
  def get_or_create_shelter_document
    shelter = Shelter.where(url:"https://www.strayrescue.org/animals-for-adoption").first

    return shelter unless shelter.nil?

    Shelter.new(
      name: "Stray Rescue of St Louis",
      url: "https://www.strayrescue.org/animals-for-adoption"
    )
  end

  # param: Hash
  # return: MonogDB document for a pet 
  # return: Nil if pet already exists
  # create new Pet Document in the MongoDB with the following parameters
  def create_pet_document_if_new(hash)
    return nil if Pet.where(profile_url: hash[:profile_url]).exists? 
    Pet.new(
      name: hash[:name],
      breed: hash[:breed],
      age: hash[:age],
      gender: hash[:gender],
      species: hash[:species],
      profile_url: hash[:profile_url],
      img_url: hash[:img_url],
      shelter_name: "Stray Rescue of St Louis"
    )
  end
  
  # param: Nokogiri Document
  # return: Array, list of paginated urls
  # finds the 'last page number' and creates an array of urls with the paginated number at the end to iterate over
  def get_paginated_urls(doc)
    doc.xpath("//div[@class='k2Pagination initialPagination']").first.content =~ /\d+ of (\d+)/
    last_page_number = $1.to_i
    (1..last_page_number).map do |n|
      "https://www.strayrescue.org/animals-for-adoption/page-#{n}"
    end
  end
 
  
  # param: Nokogiri Document
  # return: Hash 
  # creates an empty Hash in order to collect pet information to be added to the Pet Document in MongoDB
  # creates a Case Statement to iterate over the Spans of profile url  to gather content
  # create string of pet profile image url and add to Hash
  def create_pet_info_hash_from_doc(doc)
    info = {}

    img_src = doc.xpath("//div[@class='itemImageBlock']/span[@class='itemImage']/a/@href").first.value
    info[:img_url]  = "https://www.strayrescue.org#{img_src}"

    name = doc.xpath("//div[@class='itemHeader']/h2").first
	   					     .content
						     .delete("\t")
                                                     .delete("\n")
    info[:name] = name
    doc.xpath("//div[@class='itemExtraFields']/ul/li").each do |li|
      spans = li.xpath("span")
      case spans.first.content
      when /^Age:$/
        info[:age] = spans[1].content
      when /^Breed:$/
        info[:breed] = spans[1].content
      when /^Type:$/
        info[:species] = spans[1].content
      when /^Gender:$/
        info[:gender] = spans[1].content
      end
    end
  
    info
  end
  
  # param: Nokogiri Document
  # return: Array, array of pet names 
  # iterates over children of H3 spans, finds content, substitues and strips trailing white space 
  def pet_names_from_doc(doc)
    doc.xpath("//h3[@class='catItemTitle']//span[@class='a-name']").map do |span|
      span.children
	  .first
          .content
          .gsub(",", "")
          .strip
    end
  end

  # param: Nokogiri Document
  # return: Array, array of pet profile urls
  # finds the links of the unique pet profile urls and creates a string of each pet profile url
  def pet_urls_from_doc(doc)
    doc.xpath("//h3[@class='catItemTitle']/a/@href").map do |href|
      "https://www.strayrescue.org#{href}"
    end
  end

  # param: Nokogiri Document
  # return: Array, array of adopted pet urls
  # creates empty Array, collects Arrays of both pet names and pet profile urls from main web page
  # create new Hash, zips the two pet name and pet profile Arrays together
  # if the name contains 'adopted', add it to the empty Array that was created
  def adopted_pet_urls_from_doc(doc)
    adopted_pet_urls = []
  
    pet_names = pet_names_from_doc(doc)
  
    pet_urls = pet_urls_from_doc(doc)
  
    pets_hash = Hash[pet_names.zip(pet_urls)]
    pets_hash.map do |name, url|
      if name =~ /Adopted/i
        adopted_pet_urls << url
      end
    end
    adopted_pet_urls
  end

  # param: Nokogiri Document
  # return: Hash, Hash values = pet urls  
  # utilize other functions to collect pet names and pet profile urls
  # create new Hash, zips the two pet name and pet profile Arrays together
  # if name contains 'adopted', delete key/value pair from Hash 
  def unadopted_pet_urls_from_doc(doc)
    pet_names = pet_names_from_doc(doc)
    pet_urls = pet_urls_from_doc(doc)
    pets_hash = Hash[pet_names.zip (pet_urls)]
    pets_hash.map do |name, url|
      pets_hash.delete_if {|name, url| name =~/Adopted/i}
    end
    pets_hash.values
  end

end
