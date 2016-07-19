class BehaviorTransaction < ActiveRecord::Base
  belongs_to :club
  belongs_to :operator
  as_enum :resource, [:bay, :card, :member, :tab], prefix: true, map: :string
  as_enum :action, [:create, :update, :destroy, :trash, :cancel], prefix: true, map: :string

  class << self
    def cancel_member options = {}
      base_create(extract_base_attributes(options).merge(primary_resource_id: options[:member].id, resource: :member, action: :cancel))
    end

    def trash_member options = {}
      base_create(extract_base_attributes(options).merge(primary_resource_id: options[:member].id, resource: :member, action: :trash))
    end

    def trash_tab options = {}
      base_create(extract_base_attributes(options).merge(primary_resource_id: options[:tab].id, resource: :tab, action: :trash))
    end

    def cancel_tab options = {}
      base_create(extract_base_attributes(options).merge(primary_resource_id: options[:tab].id, resource: :tab, action: :cancel))
    end

    def extract_base_attributes options
      { club_id: options[:club_id], operator_id: options[:operator_id], remarks: options[:remarks] }
    end

    def base_create options = {}
      create!(options)
    end
  end
end
