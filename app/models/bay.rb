class Bay < ActiveRecord::Base
  include Identifierable, AASM
  attr_accessor :tag_names
  as_enum :location, [:first_floor, :second_floor, :third_floor, :green, :simulator], prefix: true, map: :string
  belongs_to :club
  has_many :taggables, class_name: 'BayTaggable', dependent: :destroy
  has_many :tags, through: :taggables
  aasm column: 'state' do
    state :unoccupied, initial: true
    state :occupied
    state :closed
    state :trashed
    event :check_in do
      transitions from: :unoccupied, to: :occupied
    end
    event :check_out do
      transitions from: :occupied, to: :unoccupied
    end
    event :close do
      transitions from: :unoccupied, to: :closed
    end
    event :open do
      transitions from: :closed, to: :unoccupied
    end
    event :trash do
      transitions to: :trashed
    end
  end
  before_save :set_prices
  scope :located, ->(location) { where(location_cd: location) }
  validates :name, presence: true, length: { maximum: 10 }, uniqueness: { scope: [:club_id, :location_cd] }
  validates :location, presence: true
  validates_with BayTagNamesValidator
  validates_with BayPriceValidator

  def set_tags
    BayTaggable.attach(bay: self, tag_names: self.tag_names)
  end

  class << self
    def bulk_create options = {}
      ActiveRecord::Base.transaction do
        (options[:form].start_number.to_i..options[:form].end_number.to_i).map do |number|
          name = "#{options[:form].prefix}#{number}#{options[:form].suffix}"
          raise DuplicatedBay.new unless where(club_id: options[:club].id, name: name).first.blank?
          create!(club: options[:club], name: name, location_cd: options[:form].location, weekday_price_per_hour: options[:form].weekday_price_per_hour, holiday_price_per_hour: options[:form].holiday_price_per_hour, weekday_price_per_bucket: options[:form].weekday_price_per_bucket, holiday_price_per_bucket: options[:form].holiday_price_per_bucket, tag_names: options[:form].tag_names).tap do |bay|
            bay.set_tags
          end
        end
      end
    end
  end

  protected
    def set_prices
      %w(bucket hour).each do |type|
        %w(weekday holiday).tap do |dates|
          (0..1).each do |i|
            self.send("#{dates[i - 1]}_price_per_#{type}=", self.send("#{dates[i]}_price_per_#{type}")) if !self.send("#{dates[i]}_price_per_#{type}").blank? and self.send("#{dates[i - 1]}_price_per_#{type}").blank?
          end
        end
      end
    end
end
