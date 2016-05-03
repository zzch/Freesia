class Tab < ActiveRecord::Base
  include Identifierable, AASM
  belongs_to :club
  belongs_to :user
  has_many :line_items
  aasm column: 'state' do
    state :progressing, initial: true
    state :cancelled
    state :finished
    state :voided
    event :check do
      transitions from: :progressing, to: :finished
    end
    event :trash do
      transitions from: :progressing, to: :trashed
    end
    event :cancel do
      transitions from: :finished, to: :cancelled
    end
  end
  before_create :set_sequence, :set_entrance_time

  def formatted_sequence
    self.sequence.to_s.rjust(8, '0')
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
end
