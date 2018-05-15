class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
      t.string :name
      t.string :description
      t.string :size
      t.string :precisesize
      t.boolean :allpres
      t.references :organization, index: true

      t.timestamps
    end
  end
end
