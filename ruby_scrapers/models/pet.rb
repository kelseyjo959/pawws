class Pet
  include Mongoid::Document
  field :name, type: String
  field :breed, type: String
  field :age, type: String
  field :gender, type: String
  field :species, type: String
  field :profile_url, type: String
  field :img_url, type: String
  field :pet_id, type: String
  field :shelter_name, type: String
  belongs_to :shelter
end
