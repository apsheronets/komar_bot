How do I generate a new migration?
----------------------------------

Dunno. Try this:

    echo "class YourMigration < ActiveRecord::Migration\n  def change\n  end\nend\n" > db/migrate/$(date +"%Y%m%d%H%M%S")_your_migration.rb

