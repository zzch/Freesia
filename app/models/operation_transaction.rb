class OperationTransaction < ActiveRecord::Base
  include AASM
  belongs_to :club
  belongs_to :tab
  belongs_to :member
  as_enum :type, [:income, :refund], prefix: true, map: :string

  class << self
    def income options = {}
      create!(options.merge(type: :income))
    end

    def refund options = {}
      create!(options.merge(type: :refund))
    end

    def daily_profit_in_total club
      daily(club).inject(0){|result, item| item.type_income? ? result + item.amount : result - item.amount} || 0
    end

    def daily club
      where(club_id: club.id).where('created_at >= ? AND created_at <= ?', Time.now.beginning_of_day, Time.now.end_of_day)
    end
  end
end
