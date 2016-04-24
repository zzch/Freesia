# -*- encoding : utf-8 -*-
module Trashable extend ActiveSupport::Concern
  included do
    default_scope -> { where(trashed: false) }
    scope :trashed, -> { unscope(where: :trashed).where(trashed: true) }
  end

  def trash
    update(trashed: true)
  end
end