FactoryBot.define do

  factory :category do
    name     { "親カテゴリー" }
    ancestry { nil }

    factory :child_category do
      name    { "子カテゴリー" }
      # parentメソッドが呼ばれた時にcategoryを入れる
      parent  { create(:category) }

      factory :grand_category do
        name    { "孫カテゴリー" }
        # parentメソッドが呼ばれた時にchild_categoryを入れる
        parent  { create(:child_category) }
      end
    end
  end

end