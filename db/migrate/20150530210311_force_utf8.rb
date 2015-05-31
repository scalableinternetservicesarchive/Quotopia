class ForceUtf8 < ActiveRecord::Migration
  def change
    case ActiveRecord::Base.connection.adapter_name
      when "MySQL", "Mysql2"
        execute "ALTER DATABASE #{current_database} DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci"
      when "SQLite"
        # do nothing
      when "PostgreSQL"
        # do nothing
    end
  end
end
