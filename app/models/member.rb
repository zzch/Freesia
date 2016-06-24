class Member < ActiveRecord::Base
  include Identifierable, AASM
  attr_accessor :actual_valid_months
  attr_accessor :salesman_id
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
    state :expired
    event :cancel, before: :can_be_cancel? do
      transitions from: :available, to: :cancelled
    end
    event :trash do
      transitions from: :available, to: :trashed
    end
    event :expire do
      transitions from: :available, to: :expired
    end
  end
  scope :by_club, ->(club) { where(club_id: club.id) }
  scope :ball_cards, -> { includes(:card).where(cards: { type_cd: :by_ball }) }
  scope :time_cards, -> { includes(:card).where(cards: { type_cd: :by_time }) }
  scope :unlimited_cards, -> { includes(:card).where(cards: { type_cd: :unlimited }) }
  scope :stored_cards, -> { includes(:card).where(cards: { type_cd: :stored }) }
  scope :unexpired, -> { where('expired_at >= ?', Time.now) }
  scope :expired, -> { where('expired_at < ?', Time.now) }
  validates :card_id, presence: true
  validates :actual_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :actual_valid_months, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :number, presence: true, length: { maximum: 50 }
  validates :issued_at, presence: true
  validates :remarks, length: { maximum: 30000 }

  def holder
    self.memberships.select{|membership| membership.role_holder?}.first.user
  end

  class << self
    def search club, keyword
      User.where(id: club.members.map{|member| member.users.map{|user| user.id}}.flatten).where('phone LIKE ? OR CONCAT(last_name, first_name) LIKE ?', "%#{keyword}%", "%#{keyword}%").first || raise(DoesNotExist.new)
    end

    def create_by_user options = {}
      ActiveRecord::Base.transaction do
        create_with_attributes(club: options[:club], attributes: options[:attributes], user: options[:user])
      end
    end

    def create_with_user options = {}
      ActiveRecord::Base.transaction do
        user = User.find_or_create_member(phone: options[:attributes].phone, first_name: options[:attributes].first_name, last_name: options[:attributes].last_name, gender: options[:attributes].gender)
        create_with_attributes(club: options[:club], attributes: options[:attributes], user: user)
      end
    end

    def create_with_attributes options = {}
      begin
        card = options[:club].cards.find(options[:attributes].card_id)
        issued_at = options[:attributes].issued_at.is_a?(String) ? Time.parse(options[:attributes].issued_at) : options[:attributes].issued_at
        amount = case card.type
        when :by_ball then card.initial_amount * options[:club].balls_per_bucket
        when :by_time then card.initial_amount * 60
        when :stored then card.initial_amount
        when :unlimited then 0
        end
        create!(club: options[:club],
          card: card,
          original_price: card.price,
          actual_price: options[:attributes].actual_price,
          number: options[:attributes].number,
          amount: amount,
          actual_valid_months: options[:attributes].actual_valid_months,
          issued_at: options[:attributes].issued_at,
          expired_at: issued_at + options[:attributes].actual_valid_months.to_i.months - 1.day,
          remarks: options[:attributes].remarks).tap {|member| member.memberships.create!(club: options[:club], user: options[:user], role: :holder)}.tap do |member|
          OperationTransaction.create_by_member(club: options[:club], member: member, amount: options[:attributes].actual_price)
        end
      rescue ActiveRecord::RecordNotFound
        raise InvalidCard.new
      end
    end
  end

  protected
    def can_be_cancel?
      raise InvalidState.new unless self.available?
    end
end
