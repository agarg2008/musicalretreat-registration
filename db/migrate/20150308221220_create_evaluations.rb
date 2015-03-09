class CreateEvaluations < ActiveRecord::Migration
  def change
    create_table :evaluations do |t|
      t.integer :ensemble_primary_id
      t.integer :instrument_id
      t.string :type

      t.integer :large_ensemble_part   # first or second

      t.boolean :other_instrument_english_horn
      t.boolean :other_instrument_c_trumpet
      t.boolean :other_instrument_a_clarinet

      t.text :groups
      t.boolean :require_audition
      t.boolean :studying_privately
      t.string :studying_privately_how_long
      t.integer :chamber_music_how_often   #should be 1 through 3
      t.integer :practicing_how_much       #should be 1 through 3

      # Vocal
      t.string :most_difficult_piece

      t.integer :overall_rating_large_ensemble  # should be 1 through 5
      t.integer :overall_rating_chamber
      t.integer :overall_rating_sightreading

      t.timestamps
    end
  end
end
