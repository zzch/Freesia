class Operation::CreateMembership < BaseActiveModelForm
  attr_accessor :phone, :first_name, :last_name, :gender
  validates :first_name, length: { maximum: 25 }, unless: :phone_already_in_use?
  validates :last_name, presence: true, length: { maximum: 25 }, unless: :phone_already_in_use?
  validates :gender, presence: true, inclusion: { in: User.genders.keys, message: "格式无效" }, unless: :phone_already_in_use?
  validates_with UserPhoneValidator

  def attributes
    { phone: nil, last_name: nil, first_name: nil, gender: nil }
  end

  def phone_already_in_use?
    !User.where(phone: phone.gsub(/[ -]/, '')).first.blank?
  end
end
