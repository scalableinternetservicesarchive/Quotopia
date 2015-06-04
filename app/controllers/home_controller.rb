class HomeController < ApplicationController
  # Return data depending on which tab is selected, defaults to "Trending"
  def index
    if params[:tab] == "all-time"
      if allow_twitter
        @quotes = Quote.includes(:categories)
                       .joins(:author)
                       .joins("LEFT JOIN( select id as vote_id, quote_id, value as vote_value from votes 
                               WHERE user_id = " + current_user.id.to_s + ") as user_votes on quotes.id = user_votes.quote_id") 
                       .joins("LEFT JOIN( SELECT id as favorite_ID, quote_id from favorite_quotes 
                                          WHERE user_id = " + current_user.id.to_s + ") as favorites on quotes.id = favorites.quote_id")
                       .order(vote_count: :desc)
                       .select("quotes.id, quotes.content, quotes.updated_at, authors.name as author_name, authors.id as author_id, favorite_id, vote_id, vote_value, vote_count")
                       .all.page(params[:page])
      elsif user_signed_in?
        # the LEFT JOIN is for pulling votes for the vote component in
        # quote_block
        @quotes = Quote.joins(:author)
                       .joins("LEFT JOIN( select id as vote_id, quote_id, value as vote_value from votes 
                               WHERE user_id = " + current_user.id.to_s + ") as user_votes on quotes.id = user_votes.quote_id") 
                       .joins("LEFT JOIN( SELECT id as favorite_ID, quote_id from favorite_quotes 
                                          WHERE user_id = " + current_user.id.to_s + ") as favorites on quotes.id = favorites.quote_id")
                       .order(vote_count: :desc)
                       .select("quotes.id, quotes.content, quotes.updated_at, authors.name as author_name, authors.id as author_id, favorite_id, vote_id, vote_value, vote_count")
                       .all.page(params[:page])
      else
        @quotes = Quote.joins(:author)
                       .order(vote_count: :desc)
                       .select("quotes.id, quotes.content, quotes.updated_at, authors.name as author_name, authors.id as author_id, vote_count")
                       .all.page(params[:page])
      end
      @tab_id = "all-time"

    elsif params[:tab] == "new"
      if allow_twitter
        @quotes = Quote.includes(:categories)
                       .joins(:author)
                       .joins("LEFT JOIN( SELECT id as favorite_ID, quote_id from favorite_quotes 
                                            WHERE user_id = " + current_user.id.to_s + ") as favorites on quotes.id = favorites.quote_id")
                       .joins("LEFT JOIN( select id as vote_id, quote_id, value as vote_value from votes 
                               WHERE user_id = " + current_user.id.to_s + ") as user_votes on quotes.id = user_votes.quote_id")
                       .select("quotes.id, quotes.content, quotes.updated_at, authors.name as author_name, authors.id as author_id, favorite_id, vote_id, vote_value, vote_count")
                       .order("quotes.created_at DESC")
                       .all.page(params[:page])
      elsif user_signed_in?
        @quotes = Quote.joins(:author)
                       .joins("LEFT JOIN( SELECT id as favorite_ID, quote_id from favorite_quotes 
                                            WHERE user_id = " + current_user.id.to_s + ") as favorites on quotes.id = favorites.quote_id")
                       .joins("LEFT JOIN( select id as vote_id, quote_id, value as vote_value from votes 
                               WHERE user_id = " + current_user.id.to_s + ") as user_votes on quotes.id = user_votes.quote_id")
                       .select("quotes.id, quotes.content, quotes.updated_at, authors.name as author_name, authors.id as author_id, favorite_id, vote_id, vote_value, vote_count")
                       .order("quotes.created_at DESC")
                       .all.page(params[:page])
      else
        @quotes = Quote.joins(:author)
                       .select("quotes.id, quotes.content, quotes.updated_at, authors.name as author_name, authors.id as author_id, vote_count")
                       .order("quotes.created_at DESC")
                       .all.page(params[:page])
      end
        @tab_id = "new"

    # default to trending if no tab paramenter
    else
      if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
        @interval_check = "now() - INTERVAL 1 DAY"
      else
        @interval_check = "datetime('now','1 day')"
      end
      
      if allow_twitter
        @quotes = Quote.includes(:categories)
                       .where("quotes.created_at >= " + @interval_check)
                       .joins(:author)
                       .joins("LEFT JOIN( SELECT id as favorite_ID, quote_id from favorite_quotes 
                                            WHERE user_id = " + current_user.id.to_s + ") as favorites on quotes.id = favorites.quote_id")
                       .joins("LEFT JOIN( select id as vote_id, quote_id, value as vote_value from votes 
                               WHERE user_id = " + current_user.id.to_s + ") as user_votes on quotes.id = user_votes.quote_id")
                       .order(vote_count: :desc)
                       .select("quotes.id, quotes.content, quotes.updated_at, authors.name as author_name, authors.id as author_id, favorite_id, vote_id, vote_value, vote_count")
                       .all.page(params[:page]) 
      elsif user_signed_in? 
        @quotes = Quote.where("quotes.created_at >= " + @interval_check)
                       .joins(:author)
                       .joins("LEFT JOIN( SELECT id as favorite_ID, quote_id from favorite_quotes 
                                            WHERE user_id = " + current_user.id.to_s + ") as favorites on quotes.id = favorites.quote_id")
                       .joins("LEFT JOIN( select id as vote_id, quote_id, value as vote_value from votes 
                               WHERE user_id = " + current_user.id.to_s + ") as user_votes on quotes.id = user_votes.quote_id")
                       .order(vote_count: :desc)
                       .select("quotes.id, quotes.content, quotes.updated_at, authors.name as author_name, authors.id as author_id, favorite_id, vote_id, vote_value, vote_count")
                       .all.page(params[:page])
      else
        @quotes = Quote.where("quotes.created_at >= " + @interval_check)
                       .joins(:author)
                       .order(vote_count: :desc)
                       .select("quotes.id, quotes.content, quotes.updated_at, authors.name as author_name, authors.id as author_id, vote_count")
                       .all.page(params[:page])
      end
                           
      @tab_id = "trending"
    end

    respond_to do |format|
      format.html
      format.json {render json: @quotes}
    end
  end
end
