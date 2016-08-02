class LineItem < ActiveRecord::Base
  belongs_to :club
  belongs_to :tab
  belongs_to :bay
  belongs_to :product
  belongs_to :course
  belongs_to :pay_method
  belongs_to :member
  as_enum :type, [:driving, :product, :course, :other], prefix: true, map: :string
  as_enum :charge_method, [:by_ball, :by_time], prefix: true, map: :string
  scope :driving, -> { where("type_cd = 'driving'") }
  scope :non_driving, -> { where("type_cd <> 'driving'") }

  def finished?
    !self.ended_at.blank?
  end

  def ready_to_check?
    if self.type_driving?
      !self.charge_method.blank? and !self.pay_method.blank?
    else
      !self.pay_method.blank?
    end
  end

  def pay_by_member?
    %w{ball_member time_member stored_member}.include?(self.pay_method.type.to_s)
  end

  def content
    case type
    when :driving then "#{bay.name}打位"
    when :product then product.name
    when :course then course.name
    when :other then name
    end
  end

  def actual_minutes
    actual_minutes = (((ended_at || Time.now) - started_at) / 60).round
    actual_minutes < 0 ? 0 : actual_minutes
  end

  def charge_minutes
    if self.charge_method_by_time?
      if self.actual_minutes < self.tab.minimum_charging_minutes
        0
      else
        if self.actual_minutes <= self.tab.unit_charging_minutes
          self.tab.unit_charging_minutes
        else
          charge_minutes = self.actual_minutes / self.tab.unit_charging_minutes * self.tab.unit_charging_minutes
          charge_minutes += self.tab.unit_charging_minutes if self.actual_minutes % self.tab.unit_charging_minutes > self.tab.maximum_discard_minutes
          charge_minutes
        end
      end
    end
  end

  def driving_total_amount_in_yuan
    raise InvalidLineItemType.new unless self.type_driving?
    raise InvalidPayMethod.new if !self.ready_to_check? or %w(ball_member time_member unlimited_member).include?(self.pay_method.type.to_s)
    day = %w(6 7).include?(Time.now.wday.to_s) ? 'holiday' : 'weekday'
    if self.pay_method.type_stored_member?
      case self.charge_method
      when :by_ball
        if bay_price = self.member.card.bay_prices.by_bay(self.bay).first
          bay_price.send("#{day}_price_per_bucket") * self.quantity
        else
          self.bay.send("#{day}_price_per_bucket") * self.quantity
        end
      when :by_time
        (if bay_price = self.member.card.bay_prices.by_bay(self.bay).first.try(:send, "#{day}_price_per_hour")
          bay_price
        else
          self.bay.send("#{day}_price_per_hour")
        end.to_f / 60 * self.charge_minutes).round
      end
    else
      case self.charge_method
      when :by_ball
        self.bay.send("#{day}_price_per_bucket") * self.quantity
      when :by_time
        (self.bay.send("#{day}_price_per_hour").to_f / 60 * self.charge_minutes).round
      end
    end
  end

  def update_driving_pay_method form
    if !form.member_id.blank?
      member = self.club.members.find(form.member_id)
      pay_method = PayMethod.by_card_type(member.card.type)
      update!(charge_method: form.charge_method, member_id: member.id, pay_method_id: pay_method.id)
    elsif !form.pay_method_id.blank?
      update!(charge_method: form.charge_method, pay_method_id: form.pay_method_id)
    else
      raise InvalidPayMethod.new
    end
    self.set_amount_and_total_amount
  end

  def update_non_driving_pay_method form
    if !form.member_id.blank?
      member = self.club.members.find(form.member_id)
      pay_method = PayMethod.by_card_type(member.card.type)
      update!(member_id: member.id, pay_method_id: pay_method.id)
    elsif !form.pay_method_id.blank?
      update!(pay_method_id: form.pay_method_id)
    else
      raise InvalidPayMethod.new
    end
  end

  def update_quantity quantity
    update!(quantity: quantity)
  end

  def increase_quantity_with_machine
    ActiveRecord::Base.transaction do
      raise MachineNotFound.new if self.bay.machine.blank?
      raise MachineOffline.new if self.bay.machine.offline?
      (self.quantity + 1).tap do |increased_quantity|
        update!(quantity: increased_quantity)
        Dispensation.create!(machine: self.bay.machine, club: self.club, bay: self.bay, amount: self.club.balls_per_bucket, requested_at: Time.now)
      end
    end
  end

  def update_started_at options = {}
    time = Time.now.change(hour: options[:hour], min: options[:minute], sec: 0)
    raise InvalidTime.new if !ended_at.blank? and time > ended_at
    update!(started_at: time)
  end

  def update_ended_at options = {}
    raise InvalidTime.new if (time = Time.now.change(hour: options[:hour], min: options[:minute], sec: 59)) < started_at
    update!(ended_at: time)
  end

  def swap_bay_with bay
    ActiveRecord::Base.transaction do
      bay.lock!
      raise OccupiedBay.new unless bay.unoccupied?
      self.bay.check_out!
      bay.check_in!
      bay.update!(tab: self.tab)
      update!(bay_id: bay.id)
    end
  end

  def cancel
    ActiveRecord::Base.transaction do
      self.bay.check_out! if self.type_driving?
      self.destroy!
    end
  end

  def finish
    ActiveRecord::Base.transaction do
      self.bay.check_out!
      self.update!(ended_at: Time.now)
    end
  end

  def set_amount_and_total_amount
    case type
    when :driving
      case pay_method.type
      when :ball_member then update!(total_amount: self.quantity * self.tab.balls_per_bucket)
      when :time_member then update!(total_amount: self.actual_minutes)
      when :stored_member then update!(total_amount: self.driving_total_amount_in_yuan)
      when :reception then update!(total_amount: self.driving_total_amount_in_yuan)
      when :non_reception then update!(total_amount: self.driving_total_amount_in_yuan)
      end
    when :product then update!(amount: product.price, total_amount: product.price * quantity)
    end
  end

  class << self
    def create_driving options = {}
      create!(club: options[:club], tab: options[:tab], type: :driving, bay: options[:bay], quantity: 0, started_at: Time.now)
    end

    def create_product options = {}
      raise ProductNotFound.new if (product = options[:club].products.where(id: options[:form].product_id).first).blank?
      raise InvalidProduct.new unless product.on_sale?
      (where(type_cd: :product, tab_id: options[:tab].id, product_id: product.id).first || create!(type: :product, club: options[:club], tab: options[:tab], product: product)).tap do |line_item|
        line_item.update!(quantity: (line_item.quantity || 0) + options[:form].quantity.to_i)
        line_item.set_amount_and_total_amount
      end
    end

    def create_other options = {}
      create!(type: :other, club: options[:club], tab: options[:tab], name: options[:form].name, quantity: options[:form].quantity, amount: options[:form].amount, total_amount: options[:form].quantity.to_i * options[:form].amount.to_f)
    end
  end
end
