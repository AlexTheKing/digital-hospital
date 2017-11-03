class CreateDiseases < ActiveRecord::Migration[5.1]
  def change
    create_table :diseases do |t|
      t.string :diagnosis
      t.text :symptoms
      t.integer :user_id

      t.timestamps
    end
  end
end
