class LineItem < ActiveRecord::Base
  belongs_to :club
  belongs_to :tab
  belongs_to :bay
  belongs_to :product
  belongs_to :course
  as_enum :type, [:driving, :product, :course, :other], prefix: true, map: :string
  scope :non_drivings, -> { where('type_cd <> \'driving\'') }

  def actual_minutes
    actual_minutes = (((ended_at || Time.now) - started_at) / 60).round
    actual_minutes < 0 ? 0 : actual_minutes
  end

  def charge_minutes

  end

  def update_quantity quantity
    update!(quantity: quantity)
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
