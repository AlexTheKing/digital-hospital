class AddIndexToPatientInfos < ActiveRecord::Migration[5.1]
  def change
    add_index :patient_infos, :user_id, unique: true
  end
end
