class CreatePatientInfos < ActiveRecord::Migration[5.1]
  def change
    create_table :patient_infos do |t|
      t.date :birthday
      t.string :address
      t.integer :user_id

      t.timestamps
    end
  end
end
