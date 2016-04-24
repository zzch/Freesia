class Operation::BulkCreateBayPrices < BaseActiveModelForm
  attr_accessor :bay_ids, :mode, :weekday_price_per_hour, :weekday_price_per_bucket, :holiday_price_per_hour, :holiday_price_per_bucket
  validates :weekday_price_per_hour, numericality: { greater_than: 0 }, unless: 'weekday_price_per_hour.blank?'
  validates :weekday_price_per_bucket, numericality: { greater_than: 0 }, unless: 'weekday_price_per_bucket.blank?'
  validates :holiday_price_per_hour, numericality: { greater_than: 0 }, unless: 'holiday_price_per_hour.blank?'
  validates :holiday_price_per_bucket, numericality: { greater_than: 0 }, unless: 'holiday_price_per_bucket.blank?'
  validates_with BayPriceValidator, if: 'mode == "set_price" or mode == "set_discount"'
end
