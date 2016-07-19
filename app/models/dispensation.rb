class Dispensation < ActiveRecord::Base
  belongs_to :club
  belongs_to :bay
  belongs_to :machine
  aasm column: 'state' do
    state :waiting, initial: true
    state :finished
    state :cancelled
    event :finish do
      transitions from: :waiting, to: :finished
    end
    event :cancel do
      transitions from: :waiting, to: :cancelled
    end
  end
end
