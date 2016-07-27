module Operation::BaseHelper
  def te_user_gender gender
    case gender
    when :male then '先生'
    when :female then '女士'
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

  def te_charge_method charge_method
    case charge_method
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

  def te_line_item_type type
    case type
    when :driving then '打球'
    when :product then '商品'
    when :course then '课程'
    when :other then '其它'
    end
  end

  def user_options
    User.where(id: Membership.where(member_id: @current_club.member_ids).map(&:user_id).uniq).map{|user| ["#{PinYin.abbr(user.name).upcase} | #{user.name}#{" | #{user.masked_phone}" unless user.phone.blank?}", user.id]}
  end

  def bay_options
    @current_club.bays.unoccupied.map{|bay| ["#{te_bay_location(bay.location)} | #{bay.name}", bay.id]}
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

  def driving_line_item_total_amount line_item
    if line_item.ready_to_check?
      case line_item.pay_method.type
      when :ball_member then "#{line_item.quantity * line_item.tab.balls_per_bucket}粒球"
      when :time_member then "#{line_item.charge_minutes}分钟"
      else "#{line_item.driving_total_amount_in_yuan}元"
      end
    else
      '-'
    end
  end

  def styled_changelog_type type
    array = case type
    when 'added' then ['success', '新增']
    when 'updated' then ['primary', '更新']
    when 'fixed' then ['danger', '修复']
    end
    raw("<span class=\"label label-#{array[0]}\">#{array[1]}</span>")
  end

  def pay_method_options options = {}
    ((((options[:only_stored] || false) ? options[:user].members.by_club(@current_club).stored_cards : options[:user].members.by_club(@current_club)).map{|member| ["#{member.number} #{member.card.name}", "member_id_#{member.id}"]}) || []) +
    PayMethod.without_member(@current_club).map{|pay_method| [pay_method.name, "pay_method_id_#{pay_method.id}"]}
  end

  def line_item_resource line_item
    case line_item.type
    when :product then line_item.product.name
    when :course then line_item.course.name
    when :other then line_item.name
    end
  end

  def te_member_transaction_type type
    case type
    when :income then '收入'
    when :expenditure then '支出'
    end
  end

  def te_member_transaction_action action
    case action
    when :consumption then '消费'
    when :charge then '充值'
    when :refund then '退款'
    end
  end

  def styled_tab_state state
    raw(case @tab.state
    when 'finished' then '<span class="text-success">已完成</span>'
    when 'cancelled' then '<span class="text-danger">已取消</span>'
    when 'trashed' then '<span class="text-danger">已删除</span>'
    end)
  end

  def member_transaction_amount member_transaction, type
    amount = case type
    when :before then member_transaction.send(:before_amount)
    when :current then member_transaction.send(:amount)
    when :after then member_transaction.send(:after_amount)
    end
    case member_transaction.member.card.type
    when :by_time then porto_minute(amount)
    when :by_ball then "#{amount.round}粒球"
    when :stored then porto_price(amount)
    end
  end

  def member_transaction_content member_transaction
    html = "#{transaction_record.hr_before_amount}"
    html += " <span class=\"transaction-record transaction-record-#{transaction_record.type}\">#{transaction_record.type_income? ? '+' : '-'} #{transaction_record.hr_amount}</span>"
    html += " = #{transaction_record.hr_after_amount}"
    raw(html)
  end

  def machine_model_options
    [['16年7月', :v1]]
  end

  def te_machine_model model
    case model
    when :v1 then '16年7月'
    end
  end

  def styled_role_permission permission, name
    raw(permission ? "<span class=\"text-success\"><i class=\"fa fa-check-circle\"></i> #{name}</span>" : "<span class=\"text-danger\"><i class=\"fa fa-times-circle\"></i> #{name}</span>")
  end
end