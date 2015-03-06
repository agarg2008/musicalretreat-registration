class CreateMmrChambers < ActiveRecord::Migration
  def change
    create_table :mmr_chambers do |t|
      t.column :ensemble_primary_id, :int
      t.column :instrument_id_1, :int
      t.column :string_novice, :boolean
      t.column :jazz_ensemble, :boolean

      t.timestamps
    end
  end
end
