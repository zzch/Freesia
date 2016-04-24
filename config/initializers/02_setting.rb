# -*- encoding : utf-8 -*-
require 'yaml'

module Setting
  def self.key
    HashWithIndifferentAccess.new(YAML.load_file(File.join(Rails.root, 'config', 'settings.yml')))
  end
end