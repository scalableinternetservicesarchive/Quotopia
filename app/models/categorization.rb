class Categorization < ActiveRecord::Base
  belongs_to :quote
  belongs_to :category

  trigger.after(:insert) do
    "UPDATE categories SET quote_count = quote_count + 1 WHERE NEW.category_id =  id;"
  end

  trigger.after(:delete) do
    "UPDATE categories SET quote_count = quote_count - 1 WHERE OLD.category_id = id;"
  end
end
