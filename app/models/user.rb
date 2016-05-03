class User < ActiveRecord::Base
  include Identifierable, AASM
  mount_uploader :portrait, UserPortraitUploader
  as_enum :type, [:member, :visitor, :faker], prefix: true, map: :string
  as_enum :gender, [:male, :female], prefix: true, map: :string
  has_many :verification_codes
  has_many :memberships
  has_many :members, through: :memberships
  has_many :clubs, -> { distinct }, through: :memberships
  aasm column: 'state' do
    state :available, initial: true
    state :prohibited
    event :prohibit do
      transitions from: :available, to: :prohibited
    end
  end

  def name
    if type_member?
      if !last_name.blank? and !first_name.blank?
        "#{last_name}#{first_name}"
      else
        "#{last_name}#{formatted_gender}"
      end
    elsif type_visitor?
      if !last_name.blank? and !first_name.blank?
        "#{last_name}#{first_name}"
      elsif !last_name.blank? and first_name.blank?
        "#{last_name}#{formatted_gender}"
      else
        '访客'
      end
    end
  end

  def formatted_gender
    case self.gender
    when :male then '先生'
    when :female then '女士'
    end
  end

  def masked_phone
    phone[0..2].concat('****').concat(phone[7..10])
  end

  def nearest_club latitude, longitude
    clubs.nearest(latitude, longitude)
  end

  def sign_out
    update!(token: nil)
  end

  def member_of? club
    clubs.map(&:id).include?(club.id)
  end

  def update_registration_id registration_id
    ActiveRecord::Base.transaction do
      User.where(registration_id: registration_id).update_all(registration_id: nil)
      self.update!(registration_id: registration_id)
    end
  end

  def send_push options = {}
    Push.send_by_registration_id(self.registration_id, options)
  end

  class << self
    def initial letter
      all.order(created_at: :desc).select{|user| PinYin.abbr(user.name)[0] == letter}
    end

    def sign_in phone, verification_code
      where(phone: phone).first.tap do |user|
        raise UserNotFound.new if user.nil?
        raise UnactivatedUser.new unless user.activated?
        VerificationCode.validate_sign_in(user: user, phone: phone, verification_code: verification_code)
        user.update!(token: SecureRandom.urlsafe_base64)
      end
    end

    def find_or_create_visitor attributes
      if !attributes[:phone].blank? and (exist_user = where(phone: attributes[:phone]).first)
        exist_user
      else
        create!(attributes.merge(type: :visitor))
      end
    end

    def find_or_create_member attributes
      if !attributes[:phone].blank? and (exist_user = where(phone: attributes[:phone]).first)
        exist_user
      else
        create!(attributes.merge(type: :member))
      end
    end

    def authorize token
      where(activated: true).where(token: token).first
    end
  end
end
