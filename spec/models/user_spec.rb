require 'rails_helper'

describe User do
  describe '#create' do
  it "新規登録に成功" do
    user = build(:user)
    expect(user).to be_valid
  end
  end
end