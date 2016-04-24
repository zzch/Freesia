module Operation::BaseHelper
  def te_user_gender gender
    case gender
    when :male then '男'
    when :female then '女'
    end
  end

  def te_membership_role role
    case role
    when :holder then '持卡人'
    when :user then '使用者'
    end
  end

  def te_card_type type
    case type
    when :visitor then '访客卡'
    when :by_ball then '计球卡'
    when :by_time then '计时卡'
    when :unlimited then '畅打卡'
    when :stored then '储值卡'
    end
  end

  def te_provision_item_type type
    case type
    when :primary then '打球消费'
    when :secondary then '其它消费'
    end
  end

  def bay_location_options
    Bay.locations.keys.map do |location|
      [(case location
      when 'first_floor' then '1层'
      when 'second_floor' then '2层'
      when 'third_floor' then '3层'
      when 'green' then '果岭'
      when 'simulator' then '模拟器'
      end), location]
    end
  end

  def te_bay_location location
    case location
    when :first_floor then '1层'
    when :second_floor then '2层'
    when :third_floor then '3层'
    when :green then '果岭'
    when :simulator then '模拟器'
    end
  end

  def te_extra_item_type type
    case type
    when :club_rental then '租杆费'
    when :locker then '存包费'
    when :other then '其它'
    end
  end

  def te_charging_type type
    case type
    when :by_ball then '计球'
    when :by_time then '计时'
    end
  end

  def te_course_type type
    case type
    when :open then '公开课'
    when :private then '私教课'
    end
  end

  def te_card_unit card
    case card.type
    when :by_ball then '粒球'
    when :by_time then '分钟'
    when :stored then '元'
    end
  end

  def user_options
    User.where(id: Membership.where(member_id: @current_club.member_ids).map(&:user_id).uniq).map{|user| ["#{PinYin.abbr(user.name).upcase} | #{user.name}#{" | #{user.masked_phone}" unless user.phone.blank?}", user.id]}
  end

  def bay_options
    @current_club.vacancies.map{|bay| ["#{te_bay_location(bay.location)} | #{bay.name}", bay.id]}
  end

  def coach_options
    @current_club.coaches.map{|coach| ["#{PinYin.abbr(coach.name).upcase} | #{coach.name}#{" | #{coach.phone}" unless coach.phone.blank?}", coach.id]}
  end

  def courses_options
    grouped_options_for_select(@current_club.coaches.map{|coach| ["#{PinYin.abbr(coach.name).upcase} | #{coach.name}#{" | #{coach.phone}" unless coach.phone.blank?}", coach.courses.map{|course| ["#{course.name} | #{te_course_type(course.type)}", course.id]}]})
  end

  def provision_options
    @current_club.provisions.map{|provision| ["#{PinYin.abbr(provision.name).upcase} | #{provision.name}", provision.id]}
  end

  def salesmen_options
    @current_club.salesmen.map{|salesman| ["#{PinYin.abbr(salesman.name).upcase} | #{salesman.name}", salesman.id]}
  end

  def extra_item_type_options
    ExtraItem.types.keys.map do |type|
      [(case type
      when 'club_rental' then '租杆费'
      when 'locker' then '存包费'
      when 'other' then '其它'
      end), type]
    end
  end

  def card_type_options
    Card.types.keys.map do |type|
      [(case type
      when 'by_ball' then '计球卡'
      when 'by_time' then '计时卡'
      when 'unlimited' then '畅打卡'
      when 'stored' then '储值卡'
      end), type]
    end
  end

  def card_initial_amount card
    case card.type
    when :by_ball then "#{number_with_precision(card.initial_amount, precision: 2, strip_insignificant_zeros: true)}筐球"
    when :by_time then "#{number_with_precision(card.initial_amount, precision: 2, strip_insignificant_zeros: true)}小时"
    when :stored then porto_price(card.initial_amount)
    when :unlimited then '不可用'
    end
  end

  def card_initial_amount_unit card
    case card.type
    when :by_ball then '筐球'
    when :by_time then '小时'
    when :stored then '元'
    end
  end

  def member_amount member
    case member.card.type
    when :by_ball then "#{(member.amount / member.club.balls_per_bucket).to_i}筐球"
    when :by_time then "#{(member.amount / 60).to_i}小时#{"#{(member.amount % 60).to_i}分钟" if (member.amount % 60).to_i > 0}"
    when :stored then porto_price(member.amount)
    when :unlimited then '不可用'
    end
  end

  def bay_tags tags
    raw(tags.blank? ? '<div class="mt10 text-danger">无任何标签！</div>' : tags.map{|tag| "<span class=\"label label-success\">#{tag.name}</span>"}.join(' '))
  end

  def bay_price bay
    Array.new.tap do |price|
      if !bay.weekday_price_per_hour.blank? and !bay.holiday_price_per_hour.blank? and bay.weekday_price_per_hour == bay.holiday_price_per_hour
        price << "#{porto_price(bay.weekday_price_per_hour)}/时"
      else
        price << "#{porto_price(bay.weekday_price_per_hour)}/时(平日)" unless bay.weekday_price_per_hour.blank?
        price << "#{porto_price(bay.holiday_price_per_hour)}/时(假日)" unless bay.holiday_price_per_hour.blank?
      end
      if !bay.weekday_price_per_bucket.blank? and !bay.holiday_price_per_bucket.blank? and bay.weekday_price_per_bucket == bay.holiday_price_per_bucket
        price << "#{porto_price(bay.weekday_price_per_bucket)}/筐"
      else
        price << "#{porto_price(bay.weekday_price_per_bucket)}/筐(平日)" unless bay.weekday_price_per_bucket.blank?
        price << "#{porto_price(bay.holiday_price_per_bucket)}/筐(假日)" unless bay.holiday_price_per_bucket.blank?
      end
    end.join(' ')
  end

  def styled_changelog_type type
    array = case type
    when 'added' then ['success', '新增']
    when 'updated' then ['primary', '更新']
    when 'fixed' then ['danger', '修复']
    end
    raw("<span class=\"label label-#{array[0]}\">#{array[1]}</span>")
  end

  def styled_payment_method_tag item
    if item.payment_method.blank?
      '请选择'
    else
      raw('<span class="label label-primary">' +
      if item.try(:payment_method_by_ball_member?)
        '计球卡'
      elsif item.try(:payment_method_by_time_member?)
        '计时卡'
      elsif item.try(:payment_method_unlimited_member?)
        '畅打卡'
      elsif item.payment_method_stored_member?
        '储值卡'
      elsif item.payment_method_credit_card?
        '信用卡'
      elsif item.payment_method_cash?
        '现金'
      elsif item.payment_method_check?
        '支票'
      elsif item.payment_method_on_account?
        '挂账'
      elsif item.payment_method_signing?
        '签单'
      elsif item.payment_method_coupon?
        '抵用卷'
      end + '</span>')
    end
  end

  def payment_method_tag item
    if item.try(:payment_method_by_ball_member?)
      '计球卡'
    elsif item.try(:payment_method_by_time_member?)
      '计时卡'
    elsif item.try(:payment_method_unlimited_member?)
      '畅打卡'
    elsif item.payment_method_stored_member?
      '储值卡'
    elsif item.payment_method_credit_card?
      '信用卡'
    elsif item.payment_method_cash?
      '现金'
    elsif item.payment_method_check?
      '支票'
    elsif item.payment_method_on_account?
      '挂账'
    elsif item.payment_method_signing?
      '签单'
    elsif item.payment_method_coupon?
      '抵用卷'
    end
  end

  def minutes_by_time options = {}
    if options[:minutes] < options[:club].minimum_charging_minutes
      0
    else
      unit_minutes = options[:minutes] / options[:club].unit_charging_minutes
      unit_minutes += 1 if unit_minutes.zero?
      unit_minutes += 1 if options[:minutes] > options[:club].unit_charging_minutes and (options[:minutes] % options[:club].unit_charging_minutes) >= options[:club].maximum_discard_minutes
      unit_minutes * options[:club].unit_charging_minutes
    end
  end

  def price_by_time options = {}
    if options[:minutes] < options[:club].minimum_charging_minutes
      0
    else
      hours = options[:minutes] / options[:club].unit_charging_minutes
      hours += 1 if hours.zero?
      hours += 1 if options[:minutes] > options[:club].unit_charging_minutes and (options[:minutes] % options[:club].unit_charging_minutes) >= options[:club].maximum_discard_minutes
      hours * options[:price_per_hour] * (options[:club].unit_charging_minutes.to_f / 60)
    end
  end

  def member_balance member
    case member.card.type
    when :by_ball then "#{member.ball_amount}粒球"
    when :by_time then "#{member.minute_amount}分钟"
    when :unlimited then "#{member.remaining_valid_days}天"
    when :stored then porto_price(member.deposit)
    end
  end

  def member_expense_type item
    if item.is_a? PlayingItem
      '打球消费'
    elsif item.is_a? ProvisionItem
      '餐饮消费'
    elsif item.is_a? ExtraItem
      '其它消费'
    end
  end

  def member_expense_item item
    if item.is_a? PlayingItem
      
    elsif item.is_a? ProvisionItem
      "#{item.provision.name} x #{item.quantity}"
    elsif item.is_a? ExtraItem
      "#{te_extra_item_type(item.type)}#{" - #{item.remarks}" unless item.remarks.blank?}"
    end
  end

  def member_expense_amount expense
    if expense.item.is_a? PlayingItem
      if expense.item.payment_method_by_ball_member?
        "#{expense.amount}粒球"
      elsif expense.item.payment_method_by_time_member?
        "#{expense.amount}分钟"
      elsif expense.item.payment_method_stored_member?
        porto_price(expense.amount)
      end
    elsif expense.item.is_a? ProvisionItem
      porto_price(expense.amount)
    elsif expense.item.is_a? ExtraItem
      porto_price(expense.amount)
    end
  end

  def transaction_record_type type
    case type
    when :income then '收入'
    when :expenditure then '支出'
    end
  end

  def transaction_record_action action
    case action
    when :consumption then '消费'
    when :charge then '充值'
    when :refund then '退款'
    end
  end

  def transaction_record_content transaction_record
    html = "#{transaction_record.hr_before_amount}"
    html += " <span class=\"transaction-record transaction-record-#{transaction_record.type}\">#{transaction_record.type_income? ? '+' : '-'} #{transaction_record.hr_amount}</span>"
    html += " = #{transaction_record.hr_after_amount}"
    raw(html)
  end

  def styled_role_permission permission, name
    raw(permission ? "<span class=\"text-success\"><i class=\"fa fa-check-circle\"></i> #{name}</span>" : "<span class=\"text-danger\"><i class=\"fa fa-times-circle\"></i> #{name}</span>")
  end
end
