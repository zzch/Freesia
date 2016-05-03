class Operation::MemberSetUpTab < BaseActiveModelForm
  attr_accessor :user_id, :bay_ids
  validates :user_id, presence: true
  validates_with TabBaysValidator

  def attributes
    { user_id: nil, bay_ids: nil }
  end
end
