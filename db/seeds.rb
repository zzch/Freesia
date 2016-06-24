PayMethod.create!([
  { type: :ball_member, name: '计球卡' },
  { type: :time_member, name: '计时卡' },
  { type: :stored_member, name: '储值卡' },
  { type: :unlimited_member, name: '畅打卡' },
  { type: :reception, name: '现金' },
  { type: :reception, name: '刷卡' },
  { type: :reception, name: '在线支付' },
  { type: :non_reception, name: '挂账' },
  { type: :non_reception, name: '支票' },
  { type: :non_reception, name: '签单' },
])