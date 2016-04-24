class BayUseable < ActiveRecord::Base
  belongs_to :club
  belongs_to :card
  belongs_to :bay_tag

  def self.attach options = {}
    exist_useables = where(card_id: options[:card].id)
    if exist_useables.blank? or (!exist_useables.blank? and !(exist_useables.map(&:bay_tag_id) <=> options[:bay_tag_ids].map(&:to_i)).zero?)
      exist_useables.destroy_all
      options[:bay_tag_ids].each do |bay_tag_id|
        create!(club: options[:card].club, card: options[:card], bay_tag_id: bay_tag_id)
      end
    end
  end
end
