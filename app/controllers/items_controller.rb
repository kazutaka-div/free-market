class ItemsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_item, only: [:show, :edit, :update, :destroy, :purchase_confirmation, :purchase]
  before_action :user_is_not_seller, only: [:edit, :update, :destroy]
  before_action :sold_item, only: [:edit, :update, :destroy, :purchase_confirmation, :purchase]
  before_action :user_is_seller, only: [:purchase_confirmation, :purchase]

  def index
    ladies_category = Category.find_by(name: "レディース")
    mens_category = Category.find_by(name: "メンズ")
    kids_category = Category.find_by(name: "ベビー・キッズ")

    ladies_items = Item.search_by_categories(ladies_category.subtree).new_items
    mens_items = Item.search_by_categories(mens_category.subtree).new_items
    kids_items = Item.search_by_categories(kids_category.subtree).new_items

    @new_items_arrays = [
       {category: ladies_category, items: ladies_items},
       {category: mens_category, items: mens_items},
       {category: kids_category, items: kids_items}
      ]
  end

  def show
  end

  def new
    @item = Item.new
    @item.images.build
    render layout: 'no_menu' # レイアウトファイルを指定
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to root_path, notice: "出品に成功しました"
    else
      redirect_to new_item_path, alert: @item.errors.full_messages
    end
  end

  def edit
    @item.images.build
    render layout: 'no_menu' # レイアウトファイル指定
  end

  def update
    if @item.update(item_params)
      redirect_to root_path, notice: "商品の編集が完了しました。"
    else
      redirect_to edit_item_path(@item), alert: @item.errors.full_messages
    end
  end

  def destroy
    if @item.destroy
      redirect_to root_path, notice: "商品の削除が完了しました。"
    else
      redirect_to edit_item_path(@item), alert: "商品が削除できませんでした。"
    end
  end

  def purchase_confirmation
    @card = Card.get_card(current_user.card.customer_token) if current_user.card
    render layout: 'no_menu' # レイアウトファイル指定
  end

  def purchase
    redirect_to cards_path, alert: "クレジットカードを登録してください" and return unless current_user.card.present?
    Payjp.api_key = Rails.application.credentials.payjp[:secret_key]
    customer_token = current_user.card.customer_token
    Payjp::Charge.create(
      amount: @item.price, # 商品の値段
      customer: customer_token, # 顧客、もしくはカードのトークン
      currency: 'jpy'  # 通貨の種類
    )
    @item.update(deal: "売り切れ")
    redirect_to item_path(@item), notice: "商品を購入しました"
  end

  def search
    # binding.pry
    if params[:q]
      ## params[:q]の中身があるときの処理
      params[:q][:name_cont_any] = params[:name_search].squish.split(" ")

      params[:q][:category_id_in] = [] unless params[:q][:category_id_in]
      ## ↓ @grandchild_category_idsは孫カテゴリたちのチェック状態用
      @grandchild_category_ids = params[:q][:category_id_in]
      ## ↓親カテゴリが何かしら選択されたなら@parent_categoryを定義する
      @parent_category = Category.find(params[:q][:category_id_in][0]) if params[:q][:category_id_in][0].present?
      ## ↓子カテゴリが何かしら選択されたなら@parent_categoryを定義する
      @child_category = Category.find(params[:q][:category_id_in][1]) if params[:q][:category_id_in][1].present?
      ## ↓親カテゴリが選択されていて子カテゴリが「全て」の時、親カテゴリに属しているカテゴリ全てを検索対象とする
      ## 例えば親カテゴリが「レディース」で子カテゴリが「すべて」なら「レディース」に属しているカテゴリ全てをqに入れる
      params[:q][:category_id_in] = @parent_category.subtree_ids if params[:q][:category_id_in][1] == ""
      ## ↓子カテゴリが選択されていて孫カテゴリが選択されていない時、子カテゴリに属しているカテゴリ全てを対象とする
      if params[:q][:category_id_in][1].present? && params[:q][:category_id_in][2].blank?
        params[:q][:category_id_in] = (params[:q][:category_id_in] + @child_category.subtree_ids).uniq
      end
    else
      ## params[:q]の中身がないときの処理
      params[:q] = { sorts: 'id DESC' }
    end 
    ## 共通の処理
    @q = Item.ransack(params[:q])
    @items = @q.result(distinct: true).includes(:images).page(params[:page]).per(6)
    @categories = Category.where(ancestry: nil)

    @order = [["価格が安い順", "price ASC"], ["価格が高い順", "price DESC"], ["出品が新しい順", "created_at DESC"], ["出品が古い順", "created_at ASC"]]
    @price_list = [["300~1000", "300,1000"], ["1000~5000", "1000,5000"], ["5000~10000", "5000,10000"], ["10000~30000", "10000,30000"]]
  end

  private
  def item_params
    params.require(:item).permit(
      :name,
      :price,
      :detail,
      :condition,
      :delivery_fee_payer,
      :delivery_method,
      :delivery_days,
      :prefecture_id,
      :category_id,
      images_attributes: [:src, :id, :_destroy]
      ).merge(seller_id: current_user.id)
  end

  def set_item
    @item = Item.find(params[:id])
  end

  def user_is_not_seller
    redirect_to root_path, alert: "あなたは出品者ではありません" unless @item.seller_id == current_user.id
  end

  def sold_item
    redirect_to root_path, alert: "売り切れです" if @item.deal != "販売中"
  end

  def user_is_seller
    redirect_to root_path, alert: "自分で出品した商品は購入できません" if @item.seller_id == current_user.id
  end

end
