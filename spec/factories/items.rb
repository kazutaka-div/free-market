FactoryBot.define do

  factory :item do
    name                { "商品名" }
    price               { "1000" }
    detail              { "商品詳細" }
    condition           { 0 }
    delivery_fee_payer  { 0 }
    delivery_method     { 0 }
    prefecture_id       { 1 }
    delivery_days       { 0 }
    deal                { 0 }
    # アソシエーション
    seller
    # seller_id           { 1 }
    # belongs_toの時はafter(:build)しなくてもいい
    category { create(:grand_category) }
    # 商品に紐付く画像データを作る
    after(:build) { |item| item.images << FactoryBot.build(:image) }
  end
  # traitは特殊なデータを作るときに。
  # 画像がない商品のデータを作る
  trait :no_image do
    after(:build) { |item| item.images = [] }
  end

  # 画像が6枚の商品データを作る
  trait :with_moreimage do
    after(:build) { |item| item.images << create_list(:image, 5, item: item) }
  end

  # categoryが紐づかない商品データを作る
  trait :no_category do
    after(:build) { |item| item.category = nil }
  end

end