class Machine < ActiveRecord::Base
  include AASM
  belongs_to :club
  belongs_to :bay
  as_enum :model, [:v1], prefix: true, map: :string
  aasm column: 'state' do
    state :stocked, initial: true
    state :online
    state :offline
    event :out_stock do
      transitions from: :stocked, to: :offline
    end
    event :in_stock do
      transitions to: :stocked
    end
    event :up do
      transitions from: :offline, to: :online
    end
    event :down do
      transitions from: :online, to: :offline
    end
  end
end