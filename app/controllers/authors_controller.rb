class AuthorsController < ApplicationController
  before_action :set_author, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!, :only => [:new, :edit, :update, :destroy]
  
  helper TweetsHelper

  @@column_names = ["name", "quote_count"]

  def getAuthorsOrdered
    @authors = Author.order(quote_count: :desc, updated_at: :asc)
  end

  def author_ajax 
    # endpoint syntax: http://localhost:3000/author_ajax?start=0&length=10&search=
    # note that there are 2 columns in this table:
    # Name | Quotes  
    @result = parse_datatable_ajax(@@column_names)
    @result["recordsTotal"] = Author.count
    @result["recordsFiltered"] = Author.where(@where).count
    @categories = Author.select("name, quote_count").where(@where).order(@order).limit(@length).offset(@start).to_a
    @result["data"] = @categories
    
    puts render json: @result
  end

  # GET /authors
  # GET /authors.json
  def index
    @authors = getAuthorsOrdered

    @author = Author.new

    respond_to do |format|
      format.html
      format.json {render json: @authors}
    end
  end

  # GET /authors/1
  # GET /authors/1.json
  def show
    if allow_twitter()
      @author_quotes = @author.quotes
                              .includes(:categories)
                              .joins("LEFT JOIN( SELECT id as favorite_ID, quote_id from favorite_quotes 
                                                 WHERE user_id = " + current_user.id.to_s + ") as favorites on quotes.id = favorites.quote_id")
                              .joins("LEFT JOIN( select id as vote_id, quote_id, value as vote_value from votes 
                                                 WHERE user_id = " + current_user.id.to_s + ") as user_votes on quotes.id = user_votes.quote_id") 
                              .select("quotes.id, quotes.content, favorite_id, vote_id, vote_value, vote_count")
                              .order(vote_count: :desc)
                              .all.page(params[:page])
    elsif user_signed_in?
      @author_quotes = @author.quotes
                              .joins("LEFT JOIN( SELECT id as favorite_ID, quote_id from favorite_quotes 
                                                 WHERE user_id = " + current_user.id.to_s + ") as favorites on quotes.id = favorites.quote_id")
                              .joins("LEFT JOIN( select id as vote_id, quote_id, value as vote_value from votes 
                                                 WHERE user_id = " + current_user.id.to_s + ") as user_votes on quotes.id = user_votes.quote_id") 
                              .select("quotes.id, quotes.content, favorite_id, vote_id, vote_value, vote_count")
                              .order(vote_count: :desc)
                              .all.page(params[:page])
    else 
      @author_quotes = @author.quotes
                              .order(vote_count: :desc)
                              .all.page(params[:page])
    end
  end

  # GET /authors/new
  def new
    @author = Author.new
  end

  # GET /authors/1/edit
  def edit
  end

  # POST /authors
  # POST /authors.json
  def create
    @author = Author.new(author_params)

    respond_to do |format|
      if @author.save
        @authors = getAuthorsOrdered

        format.html { redirect_to @author, notice: 'Author was successfully created.' }
        format.json { render :show, status: :created, location: @author }
        format.js {}
      else
        format.html { render :new }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /authors/1
  # PATCH/PUT /authors/1.json
  def update
    respond_to do |format|
      if @author.update(author_params)
        format.html { redirect_to @author, notice: 'Author was successfully updated.' }
        format.json { render :show, status: :ok, location: @author }
      else
        format.html { render :edit }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /authors/1
  # DELETE /authors/1.json
  def destroy
    @author.destroy
    respond_to do |format|
      format.html { redirect_to authors_url, notice: 'Author was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_author
      @author = Author.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def author_params
      params.require(:author).permit(:name)
    end
end
