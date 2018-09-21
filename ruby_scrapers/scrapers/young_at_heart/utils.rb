module YoungAtHeartUtils

  # return: MongoDB shelter document
  # creates a new Shelter Document in the MongoDB with the two following parameters
  def get_or_create_shelter_document
    shelter = Shelter.where(url:"http://www.adoptaseniorpet.com/adopt-a-pet").first
    return shelter unless shelter.nil?
    Shelter.new(
      name: "Adopt a Senior Pet",
      url: "http://www.adoptaseniorpet.com/adopt-a-pet"
    )
  end
 
  # param: Hash
  # return: MongoDB document for pet
  # return: Nil if pet already exists
  # create new Pet Document in the MongoDB with the following  parameters
  def create_pet_document_if_new(hash)
    return nil if Pet.where(profile_url: hash[:profile_url]).exists?
    Pet.new(
      name: hash[:name],
      breed: hash[:breed],
      gender: hash[:gender],
      age: hash[:age],
      img_url: hash[:img_url],
      profile_url: hash[:profile_url],
      shelter_name: "Adopt a Senior Pet"
    )
  end

  # param: Nokogiri document
  # return: Array, array of urls for adoptable dogs
  # creates a string of each dog url to iterate over
  def dog_urls_from_doc(doc)
    dog_urls = doc.xpath("//div[@class='pets filterable']//h3/a/@href").map do |pet|
      "http://www.adoptaseniorpet.com#{pet}"
  end
  end
  
  # param: Nokogiri document
  # return: Array, array of urls for adoptable cats
  # creates a string of each cat url to iterate over
  def cat_urls_from_doc(doc)
    cat_urls = doc.xpath("//div[@class='pets filterable']//h3/a/@href").map do |pet|
       "http://www.adoptaseniorpet.com#{pet}"
    end
  end

  # param: Nokogiri document
  # return: Array, array of urls for 'courtesy' pets
  # creates a string of each 'courtesy pet' url to iterate over
  def courtesy_urls_from_doc(doc)
    courtesy_urls = doc.xpath("//div[@class='pets filterable']//h3/a/@href").map do |pet|
      "http://www.adoptaseniorpet.com#{pet}"
    end
  end
  
  # param: Nokogiri document
  # return: Hash, a hash to create pet document
  # creates a Hash to be saved as a Pet Document
  def pet_details_from_doc(doc)
    pet_hash = {}
    pet_hash[:name] = doc.xpath("//div[@class= 'dog']/h2").first.content
    pet_hash[:breed] = doc.xpath("//dd[@class= 'breed']").first.content
    pet_hash[:gender] = doc.xpath("//dd[@class= 'sex']").first.content
    pet_hash[:age] = doc.xpath("//dd[@class= 'age']").first.content
    pet_hash[:img_url] = doc.xpath("//img[@class= 'pet-image']").first['src']
    pet_hash
  end

end
