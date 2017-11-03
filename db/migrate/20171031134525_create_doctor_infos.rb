class CreateDoctorInfos < ActiveRecord::Migration[5.1]
  def change
    create_table :doctor_infos do |t|
      t.date :birthday
      t.integer :user_id
      t.string :position

      t.timestamps
    end
  end
end
