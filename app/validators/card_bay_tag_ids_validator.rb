# -*- encoding : utf-8 -*-
class CardBayTagIdsValidator < ActiveModel::Validator

  def validate record
    record.bay_tag_ids = record.bay_tag_ids.flatten.select{|tag_id| !tag_id.strip.blank?}
    record.errors[:base] << '至少选择一个标签' if record.bay_tag_ids.blank?
  end
end
