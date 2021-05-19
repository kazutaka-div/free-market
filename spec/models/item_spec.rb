require 'rails_helper'

describe Item do
  describe '#create' do
  it "出品に成功" do
    # seller = create(:seller)
    # item = build(:item, seller_id: seller.id)
    item = build(:item)
    # image = build(:image) # この方法でも良いが、FactoryBotでまとめた方が綺麗。
    # item.images << image

    # sellerやimageの値が入っていないのは、item.valid?の時点では、保存されていないため。item.saveをすると、値が確認できる。
    binding.pry
    expect(item).to be_valid
  end
  
  it "画像が0枚だと出品に失敗" do
    # seller = create(:seller)
    # item = build(:item, :no_image, seller_id: seller.id)
    # traitの使い方は、buildやcreateのタイミングのみ
    item = build(:item, :no_image)
    item.valid?
    # 古城戸さんは、be_invalidの方が良い。
    # expect(item).to be_invalid
    # includeの中身が()だと、検証するものがないため、テストは通ってしまう。
    # expect(item.errors[:images]).to include()
    expect(item.errors[:images]).to include("の数が不正です")
  end

  it "画像が6枚だと出品に失敗" do
    # seller = create(:seller)
    # item = build(:item, :with_moreimage, seller_id: seller.id)
    item = build(:item, :with_moreimage)
    item.valid?
    expect(item.errors[:images]).to include("の数が不正です")
  end
  end
end