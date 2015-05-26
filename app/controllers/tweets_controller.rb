class TweetsController < ApplicationController
  before_filter :authenticate_user!, :only => [:new]

  def new
  end

  def create
      current_user.tweet(twitter_params[:message])
      respond_to do |format|
        if current_user.twitter_errors.nil?
          format.js {render action: "success", locals: {id: twitter_params[:id]}}
        else
          format.js {render action: "failure"}
        end
      end
      return
  end

  def twitter_params
    params.permit(:message, :id)
  end
end
