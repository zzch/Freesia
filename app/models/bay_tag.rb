class BayTag < ActiveRecord::Base
  belongs_to :club

  class << self
    def valid
      all.select{|bay_tag| !bay_tag.bay_taggables.blank?}
    end

    def bulk_create options = {}
      options[:names].flatten.select{|name| !name.strip.blank?}.map{|name| find_or_create_by(club_id: options[:club_id], name: name)}
    end
  end
end
