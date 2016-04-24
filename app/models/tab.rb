class Tab < ActiveRecord::Base
  include Identifierable, AASM
  belongs_to :club
  belongs_to :user
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
    self.sequence.to_s.rjust(6, '0')
  end

  protected
    def set_sequence
      self.sequence = (club.tabs.maximum(:sequence) || 0) + 1
    end

    def set_entrance_time
      self.entrance_time ||= Time.now
    end
end
