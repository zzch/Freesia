class Training < ActiveRecord::Base
  include Identifierable, AASM
  belongs_to :user
  belongs_to :lesson
  aasm column: 'state' do
    state :progressing, initial: true
    state :cancelled
    state :confirming
    state :finished
    event :cancel do
      transitions from: :progressing, to: :cancelled
    end
    event :confirm do
      transitions from: :progressing, to: :confirming
    end
    event :finish do
      transitions from: :confirming, to: :finished
    end
  end
  validates :user_id, presence: true
  validates :lesson_id, presence: true
end
