class OperationTransaction < ActiveRecord::Base
  include AASM
  belongs_to :club
  belongs_to :tab
  belongs_to :member
  as_enum :type, [:tab, :member], prefix: true, map: :string
  aasm column: 'state' do
    state :available, initial: true
    state :droped
    event :drop do
      transitions from: :available, to: :droped
    end
  end

  class << self
    def create_by_tab options = {}
      create!(options.merge(type: :tab))
    end

    def create_by_member options = {}
      create!(options.merge(type: :member))
    end
  end
end
