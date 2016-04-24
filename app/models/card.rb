class Card < ActiveRecord::Base
  include Identifierable
  attr_accessor :bay_tag_ids
  as_enum :type, [:by_ball, :by_time, :unlimited, :stored], prefix: true, map: :string
  belongs_to :club
  has_many :bay_useables, dependent: :destroy
  has_many :bay_tags, through: :bay_useables
  has_many :bay_prices
  has_many :members
  validates :name, presence: true, length: { maximum: 50 }
  validates :type, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :valid_months, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates_with CardBayTagIdsValidator

  def typed_initial_amount
    self.type_stored? ? self.initial_amount : self.initial_amount.to_i
  end

  def set_bay_tags
    BayUseable.attach(card: self, bay_tag_ids: self.bay_tag_ids)
  end

  def useable? bay
    !(self.bay_tags.pluck(:id) & bay.tags.pluck(:id)).blank?
  end

  def bay_and_prices
    card_bay_prices = Hash[self.bay_prices.map{|bay_price| [bay_price.bay_id, bay_price]}]
    ary = Bay.locations.keys.map do |location|
      self.club.bays.located(location).map do |bay|
        { name: "#{Operation::BaseController.helpers.te_bay_location(location.to_sym)} - #{bay.name}", useable?: self.useable?(bay) }.tap do |bay_hash|
          bay_hash.merge!(%w(weekday holiday).map do |day_type|
            %w(hour bucket).map do |billing_type|
              [:"#{day_type}_price_per_#{billing_type}", { original: bay.send("#{day_type}_price_per_#{billing_type}"), member: card_bay_prices[bay.id].try("#{day_type}_price_per_#{billing_type}".to_sym) }]
            end
          end.flatten.each_slice(2).to_h) if bay_hash[:useable?]
        end
      end
    end.flatten
  end

  protected
    def can_be_destroy?
      raise MemberExists.new unless self.members.blank?
    end
end
