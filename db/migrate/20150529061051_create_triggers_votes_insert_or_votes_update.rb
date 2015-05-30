# This migration was auto-generated via `rake db:generate_trigger_migration'.
# While you can edit this file, any changes you make to the definitions here
# will be undone by the next auto-generated trigger migration.

class CreateTriggersVotesInsertOrVotesUpdate < ActiveRecord::Migration
  def up
    create_trigger("votes_after_insert_row_tr", :generated => true, :compatibility => 1).
        on("votes").
        after(:insert) do
      "UPDATE quotes SET vote_count = vote_count + NEW.value WHERE id = NEW.quote_id;"
    end

    create_trigger("votes_after_update_of_value_row_tr", :generated => true, :compatibility => 1).
        on("votes").
        after(:update).
        of(:value) do
      "UPDATE quotes SET vote_count = vote_count + NEW.value WHERE id = NEW.quote_id;"
    end
  end

  def down
    drop_trigger("votes_after_insert_row_tr", "votes", :generated => true)

    drop_trigger("votes_after_update_of_value_row_tr", "votes", :generated => true)
  end
end
