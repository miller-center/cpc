class AddEnddateToPresident < ActiveRecord::Migration
  def change
    add_column :presidents, :enddate, :datetime
  end
end
