class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  helper ApplicationHelper
  after_filter :store_location

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    return unless request.get?
    if (request.path != "/users/sign_in" &&
        request.path != "/users/sign_up" &&
        request.path != "/users/password/new" &&
        request.path != "/users/password/edit" &&
        request.path != "/users/confirmation" &&
        request.path != "/users/sign_out" &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath
    end
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

  def after_sign_out_path_for(resource)
    session[:previous_url] || root_path
  end

  def allow_twitter()
        !current_user.nil? && !current_user.provider.nil? && current_user.provider.include?("twitter")
  end

  def parse_datatable_ajax(column_names)
    @draw = params[:draw]
    @start = params[:start] #row index to start at (0-indexed)
    @length = params[:length] # the number of results to return
    @search = params[:search]["value"] #the search query to filter over
    @orders = params[:order] # ordering information
    @columns = params[:columns] # column information
    
    @search ||= ""
    @orders ||= []
    @columns ||= []

    @result = {}
    @result["draw"] = @draw
    # generate "where" clause
    @where = ""
   
    unless @search.empty?
        @columns.each { |col_num, column|
            if column["searchable"] == "true" && @where != ""
                @where += " OR #{column["data"]} like '%#{@search}%'"
            elsif column["searchable"] == "true"
                @where += "#{column["data"]} like '%#{@search}%'"
            end
        }
    end 

    # generate "order" clause
    @order = ""
    unless @orders.empty?
        @orders.each do |order_num, ordering|
            if order_num.to_i > 0
                @order += ", "
            end

            @column_index = ordering["column"].to_i
            @order += " #{column_names[@column_index]} "
            
            @order += ordering["dir"].upcase
        end 
    end
    
    return @result
  end
end
