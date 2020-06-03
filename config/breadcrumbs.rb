crumb :root do
  link "メルカリ", root_path
end

crumb :item do
  show_title = Item.find_by(id: params[:id])
  link show_title.name
  parent :root
end

crumb :category do
  link "カテゴリー一覧", categories_path
  parent :root
end

crumb :category_show do
  category = Category.find(params[:id])
  link category.name
  parent :category
end