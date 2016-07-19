class Tab < ActiveRecord::Base
  include Identifierable, AASM
  belongs_to :club
  belongs_to :user
  has_many :line_items
  has_many :bays
  has_many :member_transactions
  aasm column: 'state' do
    state :progressing, initial: true
    state :cancelled
    state :finished
    state :trashed
    event :finish do
      transitions from: :progressing, to: :finished
    end
    event :trash, after: :clean_bays do
      transitions from: :progressing, to: :trashed
    end
    event :cancel, before: :can_be_cancel? do
      transitions from: :finished, to: :cancelled
    end
  end
  before_create :set_sequence, :set_entrance_time, :set_club_configuration
  default_scope { includes(:line_items) }

  def ready_to_cast_accounts?
    self.line_items.type_drivings.all?(&:finished?)
  end

  def ready_to_check?
    self.line_items.all?(&:ready_to_check?)
  end

  def formatted_sequence
    self.sequence.to_s.rjust(8, '0')
  end

  def total_amount_in_non_reception
    self.line_items.select{|line_item| line_item.pay_method.try(:type_non_reception?)}.map{|line_item| line_item.type_driving? ? line_item.driving_total_amount_in_yuan : line_item.total_amount}.reduce(:+) || 0
  end

  def total_amount_in_reception
    self.line_items.select{|line_item| line_item.pay_method.try(:type_reception?)}.map{|line_item| line_item.type_driving? ? line_item.driving_total_amount_in_yuan : line_item.total_amount}.reduce(:+) || 0
  end

  def check
    raise NotReadyToCheck.new unless self.ready_to_check?
    raise InvalidState.new unless self.progressing?
    ActiveRecord::Base.transaction do
      self.lock!
      self.departure_time = Time.now
      self.finish
      self.save!
      member_expenses = Hash.new(0)
      self.line_items.each do |line_item|
        case line_item.pay_method.type
        when :ball_member
          member_expenses[line_item.member_id] += line_item.quantity * line_item.tab.balls_per_bucket
        when :time_member
          member_expenses[line_item.member_id] += line_item.charge_minutes
        when :stored_member
          member_expenses[line_item.member_id] += if line_item.type_driving?
            line_item.driving_total_amount_in_yuan
          else
            line_item.total_amount
          end
        end if line_item.pay_by_member?
      end
      member_expenses.each do |member_id, amount|
        Member.find(member_id).tap do |member|
          raise InsufficientBalance.new if member.amount < amount
          MemberTransaction.create!(club: self.club, member: member, type: :expenditure, action: :consumption, tab: self, before_amount: member.amount, amount: amount, after_amount: member.amount - amount)
          member.update!(amount: member.amount - amount)
        end
      end
      OperationTransaction.income(club: self.club, tab: self, amount: self.total_amount_in_reception) if self.total_amount_in_reception > 0
    end
  end

  def cancel_and_refund amount
    ActiveRecord::Base.transaction do
      self.cancel!
      OperationTransaction.refund(club: self.club, tab: self, amount: amount)
      self.member_transactions.each do |member_transaction|
        MemberTransaction.create!(club: self.club, member: member_transaction.member, type: :income, action: :refund, tab: self, before_amount: member_transaction.member.amount, amount: member_transaction.amount, after_amount: member_transaction.member.amount + member_transaction.amount)
      end
    end
  end

  class << self
    def set_up_as_visitor options = {}
      ActiveRecord::Base.transaction do
        user = User.find_or_create_visitor(phone: options[:form].phone, first_name: options[:form].first_name, last_name: options[:form].last_name, gender: options[:form].gender)
        base_set_up(club: options[:club], user: user, bay_ids: options[:form].bay_ids)
      end
    end

    def set_up_as_member options = {}
      ActiveRecord::Base.transaction do
        raise InvalidUser.new if (user = options[:club].users.where(id: options[:form].user_id).first).blank?
        base_set_up(club: options[:club], user: user, bay_ids: options[:form].bay_ids)
      end
    end

    def base_set_up options = {}
      (Tab.progressing.where(club_id: options[:club].id, user_id: options[:user].id).first || create!(club: options[:club], user: options[:user])).tap do |tab|
        options[:bay_ids].each do |bay_id|
          raise InvalidBay.new if (bay = options[:club].bays.where(id: bay_id).first).blank?
          bay.check_in!
          bay.update!(tab: tab)
          LineItem.create_driving(club: options[:club], tab: tab, bay: bay)
        end
      end
    end
  end

  protected
    def set_sequence
      self.sequence = (if (maximum_sequence = club.tabs.where("sequence LIKE '#{Time.now.strftime('%y%m')}%'").maximum(:sequence)).blank?
        "#{Time.now.strftime('%y%m')}00000".to_i
      else
        "#{maximum_sequence}".start_with?(Time.now.strftime('%y%m')) ? maximum_sequence : "#{Time.now.strftime('%y%m')}00000".to_i
      end) + 1
    end

    def set_entrance_time
      self.entrance_time ||= Time.now
    end

    def set_club_configuration
      self.balls_per_bucket = self.club.balls_per_bucket
      self.minimum_charging_minutes = self.club.minimum_charging_minutes
      self.unit_charging_minutes = self.club.unit_charging_minutes
      self.maximum_discard_minutes = self.club.maximum_discard_minutes
    end

    def clean_bays
      self.bays.each{|bay| bay.check_out!}
    end

    def can_be_cancel?
      raise InvalidState.new unless self.finished?
    end
end
