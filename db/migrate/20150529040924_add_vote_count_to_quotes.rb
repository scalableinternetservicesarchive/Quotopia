class AddVoteCountToQuotes < ActiveRecord::Migration
  def change
    add_column(:quotes, :vote_count, :integer, default: 0, null: false)
  end
end
