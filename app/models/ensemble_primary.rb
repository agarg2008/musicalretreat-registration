class EnsemblePrimary < ActiveRecord::Base
  belongs_to :registration
  has_many :mmr_chambers
  has_many :prearranged_chambers
  has_many :ensemble_primary_elective_ranks
  has_many :evaluations
  has_and_belongs_to_many :electives

  accepts_nested_attributes_for :mmr_chambers
  accepts_nested_attributes_for :prearranged_chambers
  accepts_nested_attributes_for :evaluations

  def elective_ranks
    ensemble_primary_elective_ranks
  end

  def default_instrument_id
    registration.instrument_id
  end

  def primary_instrument
    Instrument.find(default_instrument_id)
  end

  def need_eval_for
    instrument_ids = (mmr_chambers + prearranged_chambers + ensemble_primary_elective_ranks).map(&:instrument_id) + [default_instrument]
    instrument_ids.compact.uniq.reject{|x| x <= 0}
  end

  #  Enums
  def self.enum_name(enum_name, value)
    names = {
      :large_ensemble_choice => [:none, :either_band_or_orchestra, :band, :orchestra, :chorus], 
      :chamber_ensemble_choice => [:none, :one_assigned, :one_prearranged_one_session, :two_assigned, :one_assigned_one_prearranged, :one_prearranged_two_sessions, :two_prearranged]
    }
    names[enum_name][value]
  end

  def self.parse_chamber_music_choice(cmc)
    num_mmr = num_prearranged = 0
    case cmc
    when 0
      num_mmr = 0; num_prearranged = 0
    when 1
      num_mmr = 1; num_prearranged = 0
    when 2
      num_mmr = 0; num_prearranged = 1
    when 3
      num_mmr = 2; num_prearranged = 0
    when 4
      num_mmr = 1; num_prearranged = 1
    when 5
      num_mmr = 0; num_prearranged = 1
    when 6
      num_mmr = 0; num_prearranged = 2
    end
    [num_mmr, num_prearranged]
  end

end
