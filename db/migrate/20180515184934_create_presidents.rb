class CreatePresidents < ActiveRecord::Migration
  def change
    create_table :presidents do |t|
      t.string :title
      t.string :fullname
      t.string :lastname
      t.datetime :birthdate
      t.datetime :deathdate
      t.string :birthplace
      t.string :deathplace
      t.string :education
      t.string :religion
      t.string :career
      t.string :party
      t.string :nicknames
      t.string :marriage
      t.string :children
      t.datetime :inaugurationdate
      t.int :number
      t.string :writings

      t.timestamps
    end
  end
end
