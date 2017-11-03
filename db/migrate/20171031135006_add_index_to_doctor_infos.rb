class AddIndexToDoctorInfos < ActiveRecord::Migration[5.1]
  def change
    add_index :doctor_infos, :user_id, unique: true
  end
end
