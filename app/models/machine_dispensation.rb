class MachineDispensation < ActiveRecord::Base
  include AASM
  belongs_to :machine
  belongs_to :club
  belongs_to :bay
  aasm column: 'state' do
    state :requested, initial: true
    state :responsed
    state :confirmed
    event :response, after: :set_responsed_at do
      transitions from: :requested, to: :responsed
    end
    event :confirm, after: :set_confirmed_at do
      transitions from: :responsed, to: :confirmed
    end
  end

  protected
    def set_responsed_at
      update!(responsed_at: Time.now)
    end

    def set_confirmed_at
      update!(confirmed_at: Time.now)
    end
end
