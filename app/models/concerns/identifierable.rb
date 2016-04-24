# -*- encoding : utf-8 -*-
module Identifierable extend ActiveSupport::Concern
  included do
    before_create :set_uuid
  end

  def set_uuid
    self.uuid ||= SecureRandom.uuid
  end

  class_methods do
    def find_uuid uuid
      self.where(uuid: uuid).first || raise(ActiveRecord::RecordNotFound)
    end
  end
end