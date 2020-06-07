crumb :root do
  link "メルカリ", root_path
end

crumb :item do |item|
  link item.name
  parent :root
end

crumb :category do
  link "カテゴリー一覧", categories_path
  parent :root
end

crumb :category_show do |category|
  link category.name
  parent :category
end