class LineItem < ActiveRecord::Base
  belongs_to :club
  belongs_to :tab
  belongs_to :bay
  belongs_to :product
  belongs_to :course
  as_enum :type, [:driving, :product, :course, :other], prefix: true, map: :string
end
