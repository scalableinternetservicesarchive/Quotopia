class AddQuoteCountToAuthors < ActiveRecord::Migration
  def change
    add_column(:authors, :quote_count, :integer, default: 0, null: false)
  end
end
