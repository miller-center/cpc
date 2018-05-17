class CreateJoinTableCollectionPresident < ActiveRecord::Migration
  def change
    create_join_table :Collections, :Presidents do |t|
      t.index [:collection_id, :president_id]
      t.index [:president_id, :collection_id]
    end
  end
end
