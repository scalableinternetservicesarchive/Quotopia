module QuotesHelper
  def cache_key_for_quotes(quotes, tab, page)
    max_updated_at = quotes.maximum(:updated_at).try(:utc).try(:to_s, :number)
    if page.nil?
      page = 1
    end
    "quotes/tab-#{tab}/page-#{page}/#{max_updated_at}"
  end

  def cache_key_for_quote(quote, display_author, render_search)
    updated_at = quote.updated_at.try(:utc).try(:to_s, :number)
    "quote/#{quote.id}/#{display_author.to_s}/#{render_search.to_s}/#{updated_at}"
  end

end
