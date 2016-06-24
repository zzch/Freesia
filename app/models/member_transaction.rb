class MemberTransaction < ActiveRecord::Base
  as_enum :type, [:income, :expenditure], prefix: true, map: :string
  as_enum :action, [:consumption, :charge, :refund], prefix: true, map: :string
  belongs_to :club
  belongs_to :member
  belongs_to :tab
end
