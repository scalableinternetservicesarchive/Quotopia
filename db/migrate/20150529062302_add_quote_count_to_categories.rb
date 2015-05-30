class AddQuoteCountToCategories < ActiveRecord::Migration
  def change
    add_column(:categories, :quote_count, :integer, default: 0, null: false)
  end
end
