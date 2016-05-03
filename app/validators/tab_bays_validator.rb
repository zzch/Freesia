# -*- encoding : utf-8 -*-
class TabBaysValidator < ActiveModel::Validator

  def validate record
    unless record.bay_ids.blank?
      record.errors[:base] << '打位无效' if !(record.bay_ids =~ /\A[0-9,]*\Z/)
      record.bay_ids = record.bay_ids.split(',').each do |bay_id|
        record.errors[:base] << '打位不存在' if (bay = Bay.where(id: bay_id).first).blank?
        record.errors[:base] << '打位状态无效' unless bay.unoccupied?
      end.map
    end
  end
end
