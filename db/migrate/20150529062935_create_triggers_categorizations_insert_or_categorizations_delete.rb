# This migration was auto-generated via `rake db:generate_trigger_migration'.
# While you can edit this file, any changes you make to the definitions here
# will be undone by the next auto-generated trigger migration.

class CreateTriggersCategorizationsInsertOrCategorizationsDelete < ActiveRecord::Migration
  def up
    create_trigger("categorizations_after_insert_row_tr", :generated => true, :compatibility => 1).
        on("categorizations").
        after(:insert) do
      "UPDATE categories SET quote_count = quote_count + 1 WHERE NEW.category_id =  id;"
    end

    create_trigger("categorizations_after_delete_row_tr", :generated => true, :compatibility => 1).
        on("categorizations").
        after(:delete) do
      "UPDATE categories SET quote_count = quote_count - 1 WHERE OLD.category_id = id;"
    end
  end

  def down
    drop_trigger("categorizations_after_insert_row_tr", "categorizations", :generated => true)

    drop_trigger("categorizations_after_delete_row_tr", "categorizations", :generated => true)
  end
end
