class Member < ActiveRecord::Base
  include Identifierable, AASM
  attr_accessor :created_at_date
  attr_accessor :expired_at_date
  belongs_to :club
  belongs_to :card
  has_many :memberships
  has_many :users, through: :memberships
  before_destroy :can_be_destroyed?
  aasm column: 'state' do
    state :available, initial: true
    state :cancelled
    state :trashed
    event :cancel, before: :can_be_cancel? do
      transitions from: :available, to: :cancelled
    end
    event :trash do
      transitions from: :available, to: :trashed
    end
  end
  scope :by_club, ->(club) { where(club_id: club.id) }
  scope :ball_cards, -> { includes(:card).where(cards: { type_cd: :by_ball }) }
  scope :time_cards, -> { includes(:card).where(cards: { type_cd: :by_time }) }
  scope :unlimited_cards, -> { includes(:card).where(cards: { type_cd: :unlimited }) }
  scope :stored_cards, -> { includes(:card).where(cards: { type_cd: :stored }) }
  scope :unexpired, -> { where('expired_at >= ?', Time.now) }
  scope :expired, -> { where('expired_at < ?', Time.now) }

  def holder
    self.memberships.select{|membership| membership.role_holder?}.first.user
  end

  class << self
    def search club, keyword
      User.where(id: club.members.map{|member| member.users.map{|user| user.id}}.flatten).where('phone LIKE ? OR CONCAT(last_name, first_name) LIKE ?', "%#{keyword}%", "%#{keyword}%").first || raise(DoesNotExist.new)
    end

    def create_with_user options = {}
      ActiveRecord::Base.transaction do
        raise InvalidCard.new unless options[:club].card_ids.include?(options[:form].card_id.to_i)
        card, user = Card.find(options[:form].card_id), User.find_or_create_member(phone: options[:form].phone, first_name: options[:form].first_name, last_name: options[:form].last_name, gender: options[:form].gender)
        amount = case card.type
        when :by_ball then card.initial_amount * options[:club].balls_per_bucket
        when :by_time then card.initial_amount * 60
        when :stored then card.initial_amount
        when :unlimited then 0
        end
        create!(club: options[:club], card: card, original_price: card.price, actual_price: options[:form].actual_price, number: options[:form].number, amount: amount, issued_at: options[:form].issued_at, expired_at: Time.parse(options[:form].issued_at) + options[:form].actual_valid_months.to_i.months - 1.day, remarks: options[:form].remarks).tap {|member| member.memberships.create!(club: options[:club], user: user, role: :holder)}.tap do |member|
          OperationTransaction.create_by_member(club: options[:club], member: member, amount: options[:form].actual_price)
        end
      end
    end
  end

  protected
    def can_be_cancel?
      raise InvalidState.new unless self.available?
    end
end
