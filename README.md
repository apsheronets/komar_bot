How do I generate a new migration?
----------------------------------

Try this:

    echo "class CreateTelegramUpdateSequence < ActiveRecord::Migration[5.0]\n  def change\n  end\nend\n" > db/migrate/$(date +"%Y%m%d%H%M%S")_create_telegram_update_sequence.rb

