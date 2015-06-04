# Moves all existing tables to utf8 charset
class ConvertTablesToUtf8 < ActiveRecord::Migration
  def change
    case ActiveRecord::Base.connection.adapter_name
      when "MySQL", "Mysql2"
        execute "ALTER TABLE authors CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
        execute "ALTER TABLE categories CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
        execute "ALTER TABLE categorizations CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
        execute "ALTER TABLE comments CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
        execute "ALTER TABLE favorite_quotes CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
        execute "ALTER TABLE quotes CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
        execute "ALTER TABLE users CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
        execute "ALTER TABLE votes CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
      when "SQLite"
        # do nothing
      when "PostgreSQL"
        # do nothing
    end
  end
end
