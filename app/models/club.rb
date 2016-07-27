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
  validates :short_name, length: { maximum: 50 }
  validates :code, presence: true, length: { maximum: 30 }, format: { with: /\A[A-Za-z0-9\-]+\z/, message: "只能使用字母、数字和中划线" }
  validates :longitude, presence: true, numericality: true
  validates :latitude, presence: true, numericality: true
  validates :address, presence: true, length: { maximum: 400 }
  validates :phone_number, presence: true, length: { maximum: 25 }
  validates :balls_per_bucket, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :minimum_charging_minutes, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :unit_charging_minutes, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :maximum_discard_minutes, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  class << self
    def nearest options = {}
      self.nearby(options[:latitude], options[:longitude]).first
    end
  end
end
