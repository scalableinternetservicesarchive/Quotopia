# This migration was auto-generated via `rake db:generate_trigger_migration'.
# While you can edit this file, any changes you make to the definitions here
# will be undone by the next auto-generated trigger migration.

class CreateTriggersQuotesInsertOrQuotesUpdateOrQuotesDelete < ActiveRecord::Migration
  def up
    create_trigger("quotes_after_insert_row_tr", :generated => true, :compatibility => 1).
        on("quotes").
        after(:insert) do
      "UPDATE authors SET quote_count = quote_count + 1 WHERE NEW.author_id = id;"
    end

    create_trigger("quotes_after_update_row_tr", :generated => true, :compatibility => 1).
        on("quotes").
        after(:update) do
      "UPDATE authors SET quote_count = quote_count + 1 WHERE NEW.author_id = id;UPDATE authors SET quote_count = quote_count - 1 WHERE OLD.author_id = id;"
    end

    create_trigger("quotes_after_delete_row_tr", :generated => true, :compatibility => 1).
        on("quotes").
        after(:delete) do
      "UPDATE authors SET quote_count = quote_count - 1 WHERE OLD.author_id = id;"
    end
  end

  def down
    drop_trigger("quotes_after_insert_row_tr", "quotes", :generated => true)

    drop_trigger("quotes_after_update_row_tr", "quotes", :generated => true)

    drop_trigger("quotes_after_delete_row_tr", "quotes", :generated => true)
  end
end
