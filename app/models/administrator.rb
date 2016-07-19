class Administrator < ActiveRecord::Base
  include AASM
  attr_accessor :password
  before_create :hash_password
  aasm column: 'state' do
    state :available, initial: true
    state :prohibited
    state :trashed
    event :prohibit do
      transitions from: :available, to: :prohibited
    end
    event :trash do
      transitions to: :trashed
    end
  end
  validates :account, presence: true, length: { in: 4..16 }, format: { with: /\A[A-Za-z0-9_]+\z/, message: "只能使用字母、数字和下划线" }
  validates :password, presence: true, confirmation: true, length: { in: 4..16 }, format: { with: /\A[A-Za-z0-9!@#$%^&*(),.?]+\z/, message: "只能使用字母、数字和符号" }, on: :create
  validates :name, presence: true, length: { maximum: 50 }

  def update_password password
    self.update(hashed_password: Digest::MD5.hexdigest(password))
  end

  def self.authenticate options = {}
    where(account: options[:account]).first.tap do |operator|
      raise AccountDoesNotExist if operator.blank? or operator.trashed?
      raise ProhibitedAdministrator if operator.prohibited? 
      raise IncorrectPassword if Digest::MD5.hexdigest(options[:password]) != operator.hashed_password
    end
  end

  protected
    def hash_password
      self.hashed_password = Digest::MD5.hexdigest(self.password)
    end
end
