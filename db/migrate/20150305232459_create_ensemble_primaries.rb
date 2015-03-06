# class CreateEnsemblePrimaries < ActiveRecord::Migration
#   def change
#     create_table :ensemble_primaries do |t|
#       t.int :registration_id
#       t.int :large_ensemble_choice
#       t.int :chamber_ensemble_choice
#       t.boolean :ack_no_morning_ensemble
#       t.boolean :want_sing_in_chorus
#       t.boolean :want_percussion_in_band

#       t.timestamps
#     end
#   end
# end

class CreateEnsemblePrimaries < ActiveRecord::Migration
  def change
    create_table :ensemble_primaries do |t|
      t.column :registration_id, :int
      t.column :large_ensemble_choice, :int
      t.column :chamber_ensemble_choice, :int
      t.column :ack_no_morning_ensemble, :boolean
      t.column :want_sing_in_chorus, :boolean
      t.column :want_percussion_in_band, :boolean
      t.timestamps
    end
  end
end
