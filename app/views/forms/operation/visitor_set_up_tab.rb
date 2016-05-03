class Operation::VisitorSetUpTab < BaseActiveModelForm
  attr_accessor :phone, :first_name, :last_name, :gender, :bay_ids
  validates :last_name, length: { maximum: 25 }
  validates :first_name, length: { maximum: 25 }
  validates :gender, presence: true, inclusion: { in: User.genders.keys, message: "格式无效" }
  validates_with UserPhoneValidator unless 'phone.blank?'
  validates_with TabBaysValidator

  def attributes
    { phone: nil, last_name: nil, first_name: nil, gender: nil, bay_ids: nil }
  end
end
