class Operation::UpdateDrivingLineItemPayMethod < BaseActiveModelForm
  attr_accessor :bay_id, :bay, :charge_method, :pay_method, :pay_method_id, :member_id, :member
  before_validation :set_bay_and_pay_method_id_or_member
  validates :charge_method, presence: true, inclusion: { in: LineItem.charge_methods.keys, message: "格式无效" }
  validates :pay_method, presence: true, format: { with: /\A(pay_method||member)_id_\d+\z/ }
  validate :must_have_pricing_policy, :can_using_bay, :pay_method_must_be_compatible_with_charge_method

  def attributes
    { bay_id: nil, bay: nil, charge_method: nil, pay_method: nil, pay_method_id: nil, member_id: nil, member: nil }
  end

  def must_have_pricing_policy
    day = %w(6 7).include?(Time.now.day) ? 'holiday' : 'weekday'
    if self.charge_method == 'by_ball'
      if member.blank?
        errors.add(:charge_method, '无该打位的价格策略') if self.bay.send("#{day}_price_per_bucket").blank?
      else
        errors.add(:charge_method, '无该打位的价格策略') if member.card.type_stored? and self.bay.send("#{day}_price_per_bucket").blank? and self.member.card.bay_prices.by_bay(self.bay).try(:"#{day}_price_per_bucket").blank?
      end
    elsif self.charge_method == 'by_time'
      if member.blank?
        errors.add(:charge_method, '无该打位的价格策略') if self.bay.send("#{day}_price_per_hour").blank?
      else
        errors.add(:charge_method, '无该打位的价格策略') if member.card.type_stored? and self.bay.send("#{day}_price_per_hour").blank? and self.member.card.bay_prices.by_bay(self.bay).try(:"#{day}_price_per_hour").blank?
      end
    end
  end

  def can_using_bay
    errors.add(:member, '无权利使用该打位') if !self.member.blank? and !self.member.card.useable?(self.bay)
  end

  def pay_method_must_be_compatible_with_charge_method
    errors.add(:pay_method, '与计费方式不匹配') if !self.member_id.blank? and
      ((self.charge_method == 'by_ball' and self.member.card.type_by_time?) or
      (self.charge_method == 'by_time' and self.member.card.type_by_ball?))
  end

  protected
    def set_bay_and_pay_method_id_or_member
      self.bay = Bay.find(self.bay_id)
      if !!(self.pay_method =~ /\A(pay_method||member)_id_\d+\z/)
        if self.pay_method.start_with?('pay_method_id_')
          self.pay_method_id = /\Apay_method_id_(\d+)\z/.match(self.pay_method).captures.first
        elsif self.pay_method.start_with?('member_id_')
          self.member_id = /\Amember_id_(\d+)\z/.match(self.pay_method).captures.first
          self.member = Member.find(self.member_id)
        end
      end
      return true
    end
end
