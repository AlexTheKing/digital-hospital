class AddTreatmentToDisease < ActiveRecord::Migration[5.1]
  def change
    add_column :diseases, :treatment, :string
  end
end
