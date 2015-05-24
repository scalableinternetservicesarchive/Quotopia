module ApplicationHelper
	def is_active(action)       
    	params[:controller] == action ? "active" : nil        
  	end
end
