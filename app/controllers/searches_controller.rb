class SearchesController < ApplicationController
    require 'ostruct'
    def search
      @has_search = false

      if params[:q] && !params[:q].empty?
        @has_search = true
        # @search_quotes = Quote.search(params[:q]).page(params[:page])
        @results = map_to_obj(search_index(params[:q]))
        @search_quotes = Kaminari.paginate_array(@results).page(params[:page]).per(7)
        # puts render json: map_to_obj(search_index(params[:q]))
      else
        @search_quotes = nil
      end
    end

    def map_to_obj(results)
        @quote_id_query = ""
        @id_query = ""

        @results = results.map do |result|
            @source = result["_source"]

            @author_name = @source["author"]["name"]
            @highlight_author_name = @source["author"]["name"]
            @content = @source["content"]
            @highlight_content = @source["content"]

            # use highlighted fields if possible
            if result.has_key?("highlight")
                @highlight_author_name = result["highlight"]["name"].join('') if result["highlight"].has_key?("name")
                @highlight_content = result["highlight"]["content"].join('') if result["highlight"].has_key?("content")
            end

            @quote_id_query += "quote_id = #{@source["id"]} OR "
            @id_query += "id = #{@source["id"]} OR "

            @quote = OpenStruct.new(
                :id => @source["id"],
                :content => @content,
                :author_id => @source["author_id"],
                :author_name => @author_name,
                :highlight_content => @highlight_content,
                :highlight_author_name => @highlight_author_name,
                :updated_at => @source["updated_at"],
            )

        end

        @quote_id_query = @quote_id_query[0...-3]
        @id_query = @id_query[0...-3]

        @vote_counts = {}
        Quote.where(@id_query).select("id, vote_count").each do |quote|
            @vote_counts[quote.id] = quote.vote_count
        end

        if !@quote_id_query.empty?
            @where = "(" + @quote_id_query + ") AND user_id = #{current_user.id.to_s}"
        else
            @where = "user_id = #{current_user.id.to_s}"
        end

        # query for the favorite, vote information if needed
        if user_signed_in?
            @favorites = {}
            FavoriteQuote.where(@where).select("quote_id, id").each do |favorite|
                @favorites[favorite.quote_id] = favorite.id
            end

            @votes = {}
            Vote.where(@where).select("quote_id, id, value as vote_value").each do |vote|
                @votes[vote.quote_id] = { :value => vote.vote_value, :id => vote.id }
            end

            if allow_twitter
                @where_twitter = ""
                if !@quote_id_query.empty?
                    @where_twitter = "WHERE #{@quote_id_query}"
                end

                @categories = {}
                Category.joins("JOIN (  SELECT quote_id, category_id
                                        FROM categorizations
                                        #{@where_twitter}) as needed_quotes
                                on needed_quotes.category_id = categories.id")
                        .select("quote_id, content").each do |category|
                            @category_object = OpenStruct.new(:content => category.content)
                            if @categories[category.quote_id].nil?
                                @categories[category.quote_id] = [@category_object]
                            else
                                @categories[category.quote_id].push(@category_object)
                            end
                        end
            end
        end
        @results = @results.map do |result|
            result.vote_count = @vote_counts[result.id]

            if user_signed_in?
                @vote = @votes[result.id]
                if !@votes[result.id].nil?
                    result.vote_value = @votes[result.id][:value]
                    result.vote_id = @votes[result.id][:id]
                end
                result.favorite_id = @favorites[result.id]
            end

            if allow_twitter
                if @categories[result.id].nil?
                    result.categories = []
                else
                    result.categories = @categories[result.id]
                end
            end

            result
        end

        #puts render json: @results
        return @results
    end

    def search_index(q)
        @query = {
            size: 310,
            query: {
                query_string: {
                    query: "*#{q}*"
                }
            },
            highlight: {
                pre_tags: ["<strong>"],
                post_tags: ["</strong>"],
                order: "score",
                fields: {
                    name: {
                        number_of_fragments: 0
                    },
                    content: {
                        number_of_fragments: 0
                    }
                }
            }
        }

        # convert the hash result from Elasticsearch into a generic object for
        # quote_block
        @results = Quote.__elasticsearch__.search(@query).results
    end

    # for testing with search results
    def search_json
        @q = params[:q].downcase
        @quotes = search_index(@q)
        puts render json: @quotes
        #render "quotes/_quote_block" #puts render body: search_index(@q).to_json
    end

    def typeahead
        @type = params[:type]

        @q = params[:q].downcase
        @query = {
            query: {
                query_string: {
                    query: "*#{@q}*"
                }
            },
            highlight: {
                pre_tags: ["<strong>"],
                post_tags: ["</strong>"],
                order: "score",
                fields: {
                    name: {
                        fragment_size: 10,
                        number_of_fragments: 0,
                        no_match_size: 20
                    },
                    content: {
                        fragment_size: 150,
                        number_of_fragments: 3,
                        no_match_size: 150
                    }
                }
            }
        }

        case @type
        when "author"
            @results = Elasticsearch::Model.search(@query, [Author]).results.map do |result|
                {:value => result["highlight"]["name"].join('')}
            end
        when "quote"
            @results = Elasticsearch::Model.search(@query, [Quote]).results.map do |result|
                {:value => result["highlight"]["content"].join('')}
            end
        when "category"
            @results = Elasticsearch::Model.search(@query, [Category]).results.map do |result|
                {:value => result["highlight"]["content"].join('')}
            end
        else
            @results = {:value => ""}
        end
        #@results = Elasticsearch::Model.search(@query, [Author, Category, Quote]).results.to_a.map(&:to_hash)
        #@mapped_results = @results.map do |result|
        #    @value = ""
        #    case result["_type"]
        #    when "author"
        #        @value = "Author - " + result["_source"]["name"]
        #    when "quote"
        #        @value = "Quote - " + result["highlight"]["content"].join("")
        #    when "category"
        #        @value = "Category - " + result["highlight"]["content"].join('')
        #    end

        #    {:value => @value}
        #end
        #@authors = Author.select("authors.name as value")
        #                 .where("authors.name LIKE ?", "%#{@q}%")

        #@categories = Category.select("categories.content as value")
        #                      .where("categories.content LIKE ?", "%#{@q}%")


        render json: @results
    end
end

