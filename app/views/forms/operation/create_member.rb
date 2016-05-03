class Operation::CreateMember < BaseActiveModelForm
  attr_accessor :phone, :first_name, :last_name, :gender, :card_id, :actual_price, :actual_valid_months, :number, :issued_at, :salesman_id, :remarks
  validates :first_name, length: { maximum: 25 }, unless: :phone_already_in_use?
  validates :last_name, presence: true, length: { maximum: 25 }, unless: :phone_already_in_use?
  validates :gender, presence: true, inclusion: { in: User.genders.keys, message: "格式无效" }, unless: :phone_already_in_use?
  validates :card_id, presence: true
  validates :actual_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :actual_valid_months, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :number, presence: true, length: { maximum: 50 }
  validates :issued_at, presence: true
  validates :remarks, length: { maximum: 30000 }
  validates_with UserPhoneValidator

  def attributes
    { phone: nil, first_name: nil, last_name: nil, gender: nil, card_id: nil, actual_price: nil, actual_valid_months: nil, number: nil, issued_at: nil, salesman_id: nil, remarks: nil }
  end

  def phone_already_in_use?
    !User.where(phone: phone.gsub(/[ -]/, '')).first.blank?
  end
end
