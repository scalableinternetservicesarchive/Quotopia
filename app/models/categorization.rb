class Categorization < ActiveRecord::Base
  belongs_to :quote, touch: true
  belongs_to :category
end
