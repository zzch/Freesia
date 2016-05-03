class Club < ActiveRecord::Base
  include Identifierable
  has_many :roles
  has_many :operators
  has_many :bays
  has_many :cards
  has_many :bay_tags
  has_many :bay_taggables
  has_many :product_categories
  has_many :products
  has_many :members
  has_many :memberships
  has_many :users, -> { distinct }, through: :memberships
  has_many :tabs
  has_many :line_items
  has_many :salesmen
  scope :nearby, ->(latitude, longitude) {
    near([latitude, longitude], 5000, unit: :km)
  }
  validates :name, presence: true, length: { maximum: 50 }

  class << self
    def nearest options = {}
      self.nearby(options[:latitude], options[:longitude]).first
    end
  end
end
