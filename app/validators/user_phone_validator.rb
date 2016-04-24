# -*- encoding : utf-8 -*-
class UserPhoneValidator < ActiveModel::Validator

  def validate record
    record.phone.try(:gsub!, /[ -]/, '')
    record.errors[:base] << '手机号格式不正确' if !(record.phone =~ /\A1\d{10}\Z/)
  end
end
