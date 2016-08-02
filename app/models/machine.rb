class Machine < ActiveRecord::Base
  include AASM
  belongs_to :club
  belongs_to :bay
  has_many :pulses, class_name: 'MachinePulse'
  has_many :dispensations, class_name: 'MachineDispensation'
  has_many :reports, class_name: 'MachineReport'
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
      transitions from: [:offline, :online], to: :online
    end
    event :down do
      transitions from: :online, to: :offline
    end
  end
  validates :model, presence: true
  validates :serial_number, presence: true, length: { maximum: 10 }, uniqueness: true
  validates :manufactured_at, presence: true

  def into_service bay
    raise InvalidState.new unless self.stocked?
    out_stock!
    bay.update!(machine_id: self.id)
    update!(club_id: bay.club.id, bay_id: bay.id)
  end

  def out_of_service
    raise InvalidState.new if self.stocked?
    in_stock!
    self.bay.try(:update!, { machine: nil })
    update!(club_id: nil, bay_id: nil)
  end

  def active options = {}
    self.out_of_stock, self.battery = options[:out_of_stock], options[:battery]
    self.up
    self.save!
  end
end
