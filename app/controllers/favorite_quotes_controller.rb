class FavoriteQuotesController < ApplicationController
  before_action :set_favorite_quote, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:user]

  # GET /favorite_quotes
  # GET /favorite_quotes.json
  def index
    @favorite_quotes = FavoriteQuote.all
  end

  # GET /favorite_quotes/1
  # GET /favorite_quotes/1.json
  def show
  end

  # GET /favorite_quotes/new
  def new
    @favorite_quote = FavoriteQuote.new
    
  end

  # GET /favorite_quotes/1/edit
  def edit
  end

  # POST /favorite_quotes
  # POST /favorite_quotes.json
  def create
    @favorite_quote = FavoriteQuote.where(quote_id: favorite_quote_params[:quote_id], user_id: favorite_quote_params[:user_id]).first
    @present = @favorite_quote.present?
    if !@present
      @favorite_quote = FavoriteQuote.new(favorite_quote_params)
    end

    respond_to do |format|
      if !@present && @favorite_quote.save
        format.html { redirect_to @favorite_quote, notice: 'Favorite quote was successfully created.' }
        format.json { render json: @favorite_quote, status: :created }
        format.js {}
      else
        if @favorite_quote.destroy
          format.html { redirect_to favorite_quotes_url, notice: 'Favorite quote was successfully destroyed.' }
          format.json { head :no_content }
          format.js {}
        else
          format.html { render :new }
          format.json { render json: @favorite_quote.errors, status: :unprocessable_entity }
          format.js {}
        end
      end
    end
  end

  # PATCH/PUT /favorite_quotes/1
  # PATCH/PUT /favorite_quotes/1.json
  def update
    respond_to do |format|
      if @favorite_quote.update(favorite_quote_params)
        format.html { redirect_to @favorite_quote, notice: 'Favorite quote was successfully updated.' }
        format.json { render :show, status: :ok, location: @favorite_quote }
      else
        format.html { render :edit }
        format.json { render json: @favorite_quote.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /favorite_quotes/1
  # DELETE /favorite_quotes/1.json
  def destroy
    respond_to do |format|
      if @favorite_quote.destroy
        format.html { redirect_to favorite_quotes_url, notice: 'Favorite quote was successfully destroyed.' }
        format.json { head :no_content }
        format.js {}
      else
        format.json { head :no_content }
      end
    end
  end

  # PUT /favorite_quotes/:quote_id/:user_id
  # PUT /favorite_quotes/:quote_id/:user_id.json
  def destroy_from_params
    @favorite = FavoriteQuote.where(quote_id: params[:quote_id], user_id: params[:user_id]).first
    if !@favorite.nil?
      @favorite.destroy
    end
    respond_to do |format|
      format.html { redirect_to favorite_quotes_url, notice: 'Favorite quote  was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /favorite_quotes/user
  def user
    if allow_twitter
      @user_favorites = 
          Quote.includes(:categories)
               .joins("INNER JOIN(  SELECT quote_id, id as favorite_id 
                                    FROM favorite_quotes 
                                    WHERE user_id = #{current_user.id}) 
                                    as favorites on quotes.id = favorites.quote_id")
               .joins(:author)
               .joins("LEFT JOIN( SELECT id as vote_id, quote_id, value as vote_value from votes 
                                  WHERE user_id = " + current_user.id.to_s + ") as user_votes on quotes.id = user_votes.quote_id") 
               .order(vote_count: :desc)
               .select("quotes.id, quotes.content, authors.name as author_name, authors.id as author_id, favorite_id, vote_id, vote_value, vote_count")
               .all
    else
      @user_favorites = 
          Quote.joins("INNER JOIN(  SELECT quote_id, id as favorite_id 
                                    FROM favorite_quotes 
                                    WHERE user_id = #{current_user.id}) 
                                    as favorites on quotes.id = favorites.quote_id")
               .joins(:author)
               .joins("LEFT JOIN( SELECT id as vote_id, quote_id, value as vote_value from votes 
                                  WHERE user_id = " + current_user.id.to_s + ") as user_votes on quotes.id = user_votes.quote_id") 
               .order(vote_count: :desc)
               .select("quotes.id, quotes.content, authors.name as author_name, authors.id as author_id, favorite_id, vote_id, vote_value, vote_count")
               .all
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_favorite_quote
      @favorite_quote = FavoriteQuote.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def favorite_quote_params
      params.require(:favorite_quote).permit(:quote_id, :user_id)
    end
end
