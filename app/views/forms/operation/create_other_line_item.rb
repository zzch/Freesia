class Operation::CreateOtherLineItem < BaseActiveModelForm
  attr_accessor :name, :quantity, :amount
  validates :name, presence: true, length: { maximum: 100 }
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def attributes
    { name: nil, quantity: nil, amount: nil }
  end
end
