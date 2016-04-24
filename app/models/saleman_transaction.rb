class SalemanTransaction < ActiveRecord::Base
  include AASM
  belongs_to :club
  belongs_to :member
  belongs_to :tab
  as_enum :type, [:member, :tab], prefix: true, map: :string
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
