class CreateDiseases < ActiveRecord::Migration[5.1]
  def change
    create_table :diseases do |t|
      t.string :diagnosis
      t.string :symptoms
      t.integer :patient_id

      t.timestamps
    end
  end
end
