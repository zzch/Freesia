# -*- encoding : utf-8 -*-
class BayTagNamesValidator < ActiveModel::Validator

  def validate record
    record.tag_names = record.tag_names.flatten.select{|tag_name| !tag_name.strip.blank?}
    record.errors[:base] << '至少填写一个标签' if record.tag_names.blank?
  end
end
