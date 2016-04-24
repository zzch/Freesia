# -*- encoding : utf-8 -*-
class TabBaysValidator < ActiveModel::Validator

  def validate record
    record.bay_ids.each do |bay_id|
      record.errors[:base] << '打位不存在' if (bay = Bay.where(id: bay_id).first).blank?
      record.errors[:base] << '打位状态无效' unless bay.unoccupied?
    end unless record.bay_ids.blank?
  end
end
