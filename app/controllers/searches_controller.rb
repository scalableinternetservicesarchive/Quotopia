class SearchesController < ApplicationController
    require 'ostruct'
    def search 
      @has_search = false
    
      if params[:q] && !params[:q].empty?
        @has_search = true
        #@search_quotes = Quote.search(params[:q]).page(params[:page])
        @results = map_to_obj(search_index(params[:q]))
        @search_quotes = Kaminari.paginate_array(@results).page(params[:page]).per(7)
      else
        @search_quotes = nil
      end
    end

    def map_to_obj(results)
        results.map do |result|
            @source = result["_source"]
            
            @author_name = @source["author"]["name"]
            @content = @source["content"]

            # use highlighted fields if possible
            if result.has_key?("highlight")
                @author_name = result["highlight"]["name"].join('') if result["highlight"].has_key?("name")
                @content = result["highlight"]["content"].join('') if result["highlight"].has_key?("content")
            end
            @quote = OpenStruct.new(
                :id => @source["id"],
                :content => @content,
                :author_id => @source["author_id"],
                :author_name => @author_name
            )
        end
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
        
        #Uncomment this to add searching on Quotes.content
        #@quotes = Quote.select("quotes.content as value")
        #               .where("quotes.content LIKE ?", "%#{@q}%")
        
        #might want to ensure capitalization in @categories?
        puts render json: @results 

    end
end 

