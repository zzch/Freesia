class Membership < ActiveRecord::Base
  include Identifierable, AASM
  as_enum :role, [:holder, :user], prefix: true, map: :string
  belongs_to :club
  belongs_to :user
  belongs_to :member
  aasm column: 'state' do
    state :available, initial: true
    state :prohibited
    event :prohibit do
      transitions from: :available, to: :prohibited
    end
  end

  class << self
    def create_with_user member, form
      ActiveRecord::Base.transaction do
        User.find_or_create_member(phone: form.phone, first_name: form.first_name, last_name: form.last_name, gender: form.gender).tap do |user|
          raise DuplicatedMembership.new if member.memberships.map(&:user_id).include?(user.id)
          create!(club: member.club, user: user, member: member, role: :user)
        end
      end
    end
  end
end
