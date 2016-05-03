class Operation::CreateProductLineItem < BaseActiveModelForm
  attr_accessor :product_id, :quantity
  validates :product_id, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  def attributes
    { product_id: nil, quantity: nil }
  end
end
