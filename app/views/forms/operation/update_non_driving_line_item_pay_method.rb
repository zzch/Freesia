class Operation::UpdateNonDrivingLineItemPayMethod < BaseActiveModelForm
  attr_accessor :pay_method, :pay_method_id, :member_id
  before_validation :set_pay_method_id_or_member_id
  validates :pay_method, presence: true, format: { with: /\A(pay_method||member)_id_\d+\z/ }
  validate :member_must_be_stored_card

  def attributes
    { pay_method: nil, pay_method_id: nil, member_id: nil }
  end

  def member_must_be_stored_card
    errors.add(:pay_method, '只能选择储值卡') if !self.member_id.blank? and !Member.find(self.member_id).card.type_stored?
  end

  def set_pay_method_id_or_member_id
    if !!(self.pay_method =~ /\A(pay_method||member)_id_\d+\z/)
      if self.pay_method.start_with?('pay_method_id_')
        self.pay_method_id = /\Apay_method_id_(\d+)\z/.match(self.pay_method).captures.first
      elsif self.pay_method.start_with?('member_id_')
        self.member_id = /\Amember_id_(\d+)\z/.match(self.pay_method).captures.first
      end
    end
    return true
  end
end
