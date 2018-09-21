class Shelter
  include Mongoid::Document
  field :name, type: String
  field :url, type: String
  has_many :pets
end
