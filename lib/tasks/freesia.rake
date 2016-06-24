namespace :data do
  desc 'Cleanup all data.'
  task reset: :environment do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:seed'].invoke
    Rake::Task['data:populate'].invoke
  end

  desc 'Populate fake data for testing.'
  task populate: :environment do
    Faker::Config.locale = 'zh-CN'
    bench = Benchmark.measure do
      Club.create!(name: '中创高尔夫', code: 'isports', longitude: 116, latitude: 39, address: '北京市朝阳区星源国际公寓D座', phone_number: '64703688', balls_per_bucket: 30, minimum_charging_minutes: 10, unit_charging_minutes: 30, maximum_discard_minutes: 10).tap do |club|
        club.operators.create!(role: Role.omnipotent(club), account: 'wanghao', password: '123456', password_confirmation: '123456', name: '王皓', phone: '13911320927')
        Bay.bulk_create(club: club, form: Operation::BulkCreateBays.new(prefix: 'A', start_number: 1, end_number: 20, tag_names: ['普通打位'], location: :first_floor, weekday_price_per_hour: 108, holiday_price_per_hour: 128))
        Bay.bulk_create(club: club, form: Operation::BulkCreateBays.new(prefix: 'V', start_number: 1, end_number: 6, tag_names: ['VIP打位'], location: :second_floor, weekday_price_per_hour: 228, holiday_price_per_hour: 268))
        card = Card.create!(club: club, type: :by_time, name: '6000元计时卡', price: 6000, valid_months: 12, bay_tag_ids: %w{1}, initial_amount: 168)
        card.set_bay_tags
        Card.create!(club: club, type: :by_ball, name: '8000元计球卡', price: 8000, valid_months: 12, bay_tag_ids: %w{1}, initial_amount: 800).tap do |ball_card|
          ball_card.set_bay_tags
        end
        Card.create!(club: club, type: :stored, name: '10000元储值卡', price: 10000, valid_months: 12, bay_tag_ids: %w{1 2}, initial_amount: 10000).tap do |stored_card|
          stored_card.set_bay_tags
        end
        latest_time = Time.now
        100.downto(1) do |i|
          latest_time -= rand(3..20).days
          form = Operation::CreateMember.new(phone: "1#{rand(10..99)}-#{rand(1000..9999)}-#{rand(1000..9999)}", first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, gender: ['male', 'female'].sample, card_id: card.id, actual_price: card.price, actual_valid_months: card.valid_months, number: "V#{i.to_s.rjust(4, '0')}", issued_at: latest_time.strftime('%Y-%m-%d'), remarks: Faker::Lorem.paragraph(10))
          if form.valid?
            Member.create_with_user(club: club, attributes: form)
          else
            puts "**** #{form.errors.full_messages}"
          end
        end
        ball_card_number, stored_card_number = 0, 0
        User.all.each do |user|
          if rand(0..2).zero?
            card = Card.type_by_balls.first
            ball_card_number += 1
            Member.create_by_user(club: club, attributes: Member.new(card_id: card.id, actual_price: card.price, actual_valid_months: card.valid_months, number: "B#{ball_card_number.to_s.rjust(4, '0')}", issued_at: Time.now, remarks: Faker::Lorem.paragraph(10)), user: user)
          end
          if rand(0..3).zero?
            card = Card.type_storeds.first
            stored_card_number += 1
            Member.create_by_user(club: club, attributes: Member.new(card_id: card.id, actual_price: card.price, actual_valid_months: card.valid_months, number: "C#{stored_card_number.to_s.rjust(4, '0')}", issued_at: Time.now, remarks: Faker::Lorem.paragraph(10)), user: user)
          end
        end
        ProductCategory.create!(club: club, name: '饮品').tap do |category|
          Product.create!([
            { club: club, category: category, name: '可乐', price: 10 },
            { club: club, category: category, name: '雪碧', price: 10 },
            { club: club, category: category, name: '美年达', price: 10 },
            { club: club, category: category, name: '脉动', price: 20 },
            { club: club, category: category, name: '红牛', price: 20 }
          ])
        end
        ProductCategory.create!(club: club, name: '简餐').tap do |category|
          Product.create!([
            { club: club, category: category, name: '红烧牛肉面', price: 28 },
            { club: club, category: category, name: '宫保鸡丁盖饭', price: 38 },
            { club: club, category: category, name: '鱼香肉丝盖饭', price: 38 },
            { club: club, category: category, name: '卤肉饭', price: 38 },
            { club: club, category: category, name: '麻辣小龙虾', price: 98 }
          ])
        end
      end
    end
    p "finished in #{bench.real} second(s)"
  end

  def fake_image_file options = {}
    if options[:allow_blank]
      rand(1..10) > 3 ? File.open(File.join(Rails.root, 'public', 'abstract_images', "#{rand(1..200).to_s.rjust(3, '0')}.jpg")) : nil
    else
      File.open(File.join(Rails.root, 'public', 'abstract_images', "#{rand(1..200).to_s.rjust(3, '0')}.jpg"))
    end
  end
end