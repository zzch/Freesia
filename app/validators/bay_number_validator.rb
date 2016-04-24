# -*- encoding : utf-8 -*-
class BayNumberValidator < ActiveModel::Validator

  def validate record
    record.errors[:base] << '开始编号必须小于结束编号' if !record.start_number.blank? and !record.end_number.blank? and record.start_number >= record.end_number
  end
end
