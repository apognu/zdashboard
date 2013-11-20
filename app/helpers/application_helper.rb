module ApplicationHelper
  def paginate(items_per_page, item_count, current_page = 1)
    page_count = (item_count / items_per_page).to_i
    page_count += 1 if (item_count % items_per_page) > 0

    pages = [
      current_page - 20,
      current_page - 10,
      current_page - 3,
      current_page - 2,
      current_page - 1,
      current_page,
      current_page + 1,
      current_page + 2,
      current_page + 3,
      current_page + 10,
      current_page + 20
    ]

    pages.reject! { | item | item < 1 }
    pages.reject! { | item | item > page_count }

    return pages
  end
end
