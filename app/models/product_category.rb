class ProductCategory < ActiveRecord::Base
  include Identifierable
  belongs_to :club
  has_many :products, foreign_key: :category_id
  validates :name, presence: true, length: { maximum: 25 }
end
