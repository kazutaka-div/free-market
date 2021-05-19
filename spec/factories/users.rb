FactoryBot.define do

  factory :user do
    nickname              { "テスト太郎" }
    birthday              { "2020-01-01" }
    first_name            { "テスト" }
    last_name             { "太郎" }
    first_name_reading    { "テスト" }
    last_name_reading     { "タロウ" }
    sequence(:email)      { |n| "tester#{n}@example.com" }
    password              { "password1" }
    password_confirmation { "password1" }
    # userモデルがsellerと呼ばれた時のデータ
    factory :seller do
      nickname              { "セラー太郎" }
      first_name            { "セラー" }
      last_name             { "太郎" }
      first_name_reading    { "セラー" }
      last_name_reading     { "タロウ" }
    end

  end

end
