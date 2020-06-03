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

# crumb :projects do
#   link "Projects", projects_path
# end

# crumb :project do |project|
#   link project.name, project_path(project)
#   parent :projects
# end

# crumb :project_issues do |project|
#   link "Issues", project_issues_path(project)
#   parent :project, project
# end

# crumb :issue do |issue|
#   link issue.title, issue_path(issue)
#   parent :project_issues, issue.project
# end

# If you want to split your breadcrumbs configuration over multiple files, you
# can create a folder named `config/breadcrumbs` and put your configuration
# files there. All *.rb files (e.g. `frontend.rb` or `products.rb`) in that
# folder are loaded and reloaded automatically when you change them, just like
# this file (`config/breadcrumbs.rb`).