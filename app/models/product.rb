class Product < ActiveRecord::Base
  include Identifierable, AASM
  belongs_to :category, class_name: 'ProductCategory'
  validates :category_id, presence: true
  validates :name, presence: true, length: { maximum: 25 }
  validates :price, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100000 }
  aasm column: 'state' do
    state :on_sale, initial: true
    state :discontinued
    state :out_of_stock
  end
end
