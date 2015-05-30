module CategoriesHelper
  def cache_key_for_category_quote(category, quote, page)
    category_updated_at = category.updated_at.try(:utc).try(:to_s, :number)
    quote_updated_at = quote.updated_at.try(:utc).try(:to_s, :number)
    if page.nil?
      page = 1
    end
    "category/page-#{page}/#{category.id}/#{category_updated_at}/#{quote.id}/#{quote_updated_at}"
  end

  def cache_key_for_category_table(categories)
    # max_updated_at = Category.maximum(:updated_at).try(:utc).try(:to_s, :number)
    "categories/#{categories.length}"
  end
end
