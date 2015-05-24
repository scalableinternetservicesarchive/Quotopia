class SearchesController < ApplicationController
    
    def search 
      @has_search = false
    
      if params[:q] && !params[:q].empty?
        @has_search = true
        @search_quotes = Quote.search(params[:q]).page(params[:page])
      else
        @search_quotes = nil
      end
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
                {:value => result["_source"]["name"]}
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

