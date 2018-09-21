#!/usr/bin/env ruby

module NYCShelterUtils

  # return: MongoDB shelter document
  # creates a new Shelter Document in the MongoDB with the two following parameters
  def get_or_create_shelter_document
    shelter = Shelter.where(url:"http://nycaccpets.shelterbuddy.com/").first
    return shelter unless shelter.nil?

    Shelter.new(
      name: "NYC Shelter Buddy",
      url: "http://nycaccpets.shelterbuddy.com/"
    )
  end


  # param: Hash
  # return: Mongoid pet document
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
      pet_id: hash[:pet_id],
      shelter_name: "NYC Shelter Buddy"
    )
  end


  # param: Nokogiri document
  # return: Array of pet urls
  # create string of each pet profile url to iterate over
  def pet_urls_from_doc(doc)
    doc.xpath("//td[@class='searchResultsCell']/a/@href").map do |href|
      link = href.content.gsub(/page=\d+/, "page=0")
      "http://nycaccpets.shelterbuddy.com/#{link}"
    end.uniq
  end


  # param: Nokogiri document
  # return: Hash
  # return: Nil if pet has no image
  # create empty Hash
  # create Case Statement to iterate over pet profile to collect information to be added to MongoDB
  def create_pet_info_hash_from_doc(doc)
    # below if nil then function will return nil
    return(nil) if doc.xpath("//img[@id='petDefaultPic']").first.nil?
    pet_hash = {}
    pet_name_header  = doc.xpath("//legend[@class='animalNameHeader']").first.content
    pet_name_header =~ /\W+(.*)'s Details/
    pet_hash[:name] = $1
    
    img_src = doc.xpath("//img[@id='petDefaultPic']").first.attributes['src'].value
    pet_hash[:img_url] = "http://nycaccpets.shelterbuddy.com/#{img_src}"
 
    pet_hash[:pet_id] = doc.xpath("//td[@class='viewAnimalCell']//b").first.content

    # array of table details keys
    viewAnimalHeading = doc.xpath("//table[@id='detailsTable']//td[@class='viewAnimalHeading']").map {|c| c.content}
    # array of table details values
    viewAnimalCell = doc.xpath("//table[@id='detailsTable']//td[@class='viewAnimalCell']").map {|c| c.content}
   # collect data pertinent on webpage for DB 
    viewAnimalHeading.each_with_index do |heading, index|
      case heading
      when /^Type$/
        pet_hash[:species] = viewAnimalCell[index]
      when /^Breed$/ 
        pet_hash[:breed] = viewAnimalCell[index]
      when /^Sex$/
        pet_hash[:gender] = viewAnimalCell[index]
      when /^Age$/
        pet_hash[:age] = viewAnimalCell[index]
      end
    end
    pet_hash 
  end

  # param: Nokogiri document
  # return: String, current url being iterated over
  def current_url_from_doc(doc)
    current_page_number = doc.xpath("//b").first.content.to_i
    current_url = "http://nycaccpets.shelterbuddy.com/search/searchResults.asp?advanced=0&searchType=4&animalType=2%2C15%2C3%2C16%2C15%2C16%2C86&datelostfoundmonth=11&datelostfoundday=25&datelostfoundyear=2017&submitbtn=Find+Animals&pagesize=15&task=view&searchTypeId=4&tpage=#{current_page_number}"
  end

  # param: String, url
  # return: String, updated url to re-iterate over
  def increment_url(url)
    nok = Nokogiri::HTML(open(url), nil, 'UTF-8')
    n = nok.xpath("//b").first.content.to_i
    requested_url = "http://nycaccpets.shelterbuddy.com/search/searchResults.asp?advanced=0&searchType=4&animalType=2%2C15%2C3%2C16%2C15%2C16%2C86&datelostfoundmonth=11&datelostfoundday=25&datelostfoundyear=2017&submitbtn=Find+Animals&pagesize=15&task=view&searchTypeId=4&tpage=#{n+1}"
  end



end
