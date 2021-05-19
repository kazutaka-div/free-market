FactoryBot.define do

  factory :image do
    src { File.open("spec/fixtures/test_1.png") }
  end

end
