class BayPrice < ActiveRecord::Base
  belongs_to :club
  belongs_to :card
  belongs_to :bay

  class << self
    def bulk_create options = {}
      ActiveRecord::Base.transaction do
        options[:form].bay_ids.each do |bay_id|
          bay = options[:club].bays.find(bay_id)
          bay_price = find_or_initialize_by(club_id: options[:club].id, card_id: options[:card].id, bay_id: bay.id)
          if options[:form].mode == 'set_price'
            bay_price.update!({ weekday_price_per_hour: options[:form].weekday_price_per_hour,
              holiday_price_per_hour: options[:form].holiday_price_per_hour,
              weekday_price_per_bucket: options[:form].weekday_price_per_bucket,
              holiday_price_per_bucket: options[:form].holiday_price_per_bucket }.select{|k, v| !v.empty?})
          elsif options[:form].mode == 'set_discount'
            raise OriginPriceNotFound.new if (!options[:form].weekday_price_per_hour.blank? and bay.weekday_price_per_hour.blank?) or
              (!options[:form].holiday_price_per_hour.blank? and bay.holiday_price_per_hour.blank?) or
              (!options[:form].weekday_price_per_bucket.blank? and bay.weekday_price_per_bucket.blank?) or
              (!options[:form].holiday_price_per_bucket.blank? and bay.holiday_price_per_bucket.blank?)
            raise InvalidDiscount.new if (!options[:form].weekday_price_per_hour.blank? and options[:form].weekday_price_per_hour.to_d >= 10) or
              (!options[:form].holiday_price_per_hour.blank? and options[:form].holiday_price_per_hour.to_d >= 10) or
              (!options[:form].weekday_price_per_bucket.blank? and options[:form].weekday_price_per_bucket.to_d >= 10) or
              (!options[:form].holiday_price_per_bucket.blank? and options[:form].holiday_price_per_bucket.to_d >= 10)
            bay_price.update!({ weekday_price_per_hour: ((options[:form].weekday_price_per_hour.blank? or bay.weekday_price_per_hour.blank?) ? nil : (options[:form].weekday_price_per_hour.to_d * 0.1 * bay.weekday_price_per_hour).round),
              holiday_price_per_hour: ((options[:form].holiday_price_per_hour.blank? or bay.holiday_price_per_hour.blank?) ? nil : (options[:form].holiday_price_per_hour.to_d * 0.1 * bay.holiday_price_per_hour).round),
              weekday_price_per_bucket: ((options[:form].weekday_price_per_bucket.blank? or bay.weekday_price_per_bucket.blank?) ? nil : (options[:form].weekday_price_per_bucket.to_d * 0.1 * bay.weekday_price_per_bucket).round),
              holiday_price_per_bucket: ((options[:form].holiday_price_per_bucket.blank? or bay.holiday_price_per_bucket.blank?) ? nil : (options[:form].holiday_price_per_bucket.to_d * 0.1 * bay.holiday_price_per_bucket).round) }.select{|k, v| !v.blank?})
          end
        end
      end
    end

    def bulk_destroy options = {}
      where(card_id: options[:card].id, bay_id: options[:form].bay_ids.map do |bay_id|
        options[:club].bays.find(bay_id).id
      end).destroy_all
    end
  end
end
