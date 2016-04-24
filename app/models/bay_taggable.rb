class BayTaggable < ActiveRecord::Base
  belongs_to :club
  belongs_to :bay
  belongs_to :tag, class_name: 'BayTag'

  def self.attach options = {}
    where(bay_id: options[:bay].id).destroy_all
    BayTag.bulk_create(club_id: options[:bay].club_id, names: options[:tag_names]).each{|tag| create!(club: options[:bay].club, bay: options[:bay], tag: tag)}
  end
end
