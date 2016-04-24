class Operation::BulkCreateBays < BaseActiveModelForm
  attr_accessor :prefix, :suffix, :start_number, :end_number, :tag_names, :location, :weekday_price_per_hour, :holiday_price_per_hour, :weekday_price_per_bucket, :holiday_price_per_bucket
  validates :prefix, length: { maximum: 8 }, unless: 'prefix.blank?'
  validates :suffix, length: { maximum: 8 }, unless: 'suffix.blank?'
  validates :start_number, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :end_number, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 2, less_than_or_equal_to: 999 }
  validates :location, presence: true
  validates_with BayNumberValidator
  validates_with BayTagNamesValidator
  validates_with BayPriceValidator
end
