class PayMethod < ActiveRecord::Base
  belongs_to :club
  as_enum :type, [:ball_member, :time_member, :stored_member, :unlimited_member, :reception, :non_reception], prefix: true, map: :string
  scope :without_member, ->(club) { where("type_cd NOT IN ('ball_member', 'time_member', 'stored_member', 'unlimited_member') AND (club_id IS NULL OR club_id = ?)", club.id) }

  class << self
    def by_card_type type
      case type
      when :by_ball then type_ball_members.where(club_id: nil).first
      when :by_time then type_time_members.where(club_id: nil).first
      when :stored then type_stored_members.where(club_id: nil).first
      when :unlimited then type_unlimited_members.where(club_id: nil).first
      end
    end
  end
end
