class Role < ActiveRecord::Base
  PermissionMapping = {
    manage_role: { roles: [:new, :create, :edit, :update] },
    manage_operator: { operators: [:new, :create, :edit, :update] },
    manage_bay: { bays: [:new, :create, :edit, :update, :bulk_new, :bulk_create, :open, :close] },
    manage_card: { cards: [:new, :create, :edit, :update], bay_prices: [:bulk_new, :bulk_create] },
    manage_salesman: { salesmen: [:new, :create, :edit, :update] },
    manage_product: { product_categories: [:new, :create, :edit, :update], products: [:new, :create, :edit, :update] },
    manage_coach: { coaches: [:new, :create, :edit, :update] },
    manage_course: { courses: [:new, :create, :edit, :update] },
    create_member: { members: [:new, :create] },
    update_member: { members: [:edit, :update] },
    cancel_member: { members: [:cancel_confirmation, :cancel] },
    trash_member: { members: [:trash_confirmation, :trash] }
  }
  belongs_to :club
  has_many :operators

  def permission_certificate options = {}
    raise PermissionDenied.new if !(value = Role::PermissionMapping.values.select{|mapping| mapping[options[:controller].to_sym].try(:include?, options[:action].to_sym)}.first).blank? \
      and !send(Role::PermissionMapping.key(value))
  end

  class << self
    def omnipotent club
      club.roles.where(omnipotent: true).first || create!(club: club, name: '管理员', omnipotent: true, manage_role: true, manage_operator: true, manage_bay: true, manage_card: true, manage_salesman: true, manage_product: true, manage_coach: true, manage_course: true, create_member: true, update_member: true, cancel_member: true, trash_member: true)
    end
  end
end
