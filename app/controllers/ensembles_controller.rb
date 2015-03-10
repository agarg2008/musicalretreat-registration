class EnsemblesController < ApplicationController

  include RegistrationGating

  before_filter :authorize, :only => [:primary]

  def primary
    user = User.find(session[:user_id])
    if user && user.has_current_registration
      @registration = user.most_recent_registration
      unless @registration.instrument_id
        flash[:notice] = "You registered as a non-particpant -- no ensemble choice for you"
        redirect_to :controller => :registration, :action => :index
      end
    else
      flash[:notice] = "You do not have a current registration"
      Event.log("#{user.email} tried to choose ensembles but no registration")
      redirect_to :controller => :registration, :action => "index"
    end
    @ensemble_primary = EnsemblePrimary.new(:registration_id => @registration.id)
    flash[:ensemble_primary_id] = @ensemble_primary.id
  end

  def primary_chamber
    @ensemble_primary = EnsemblePrimary.new(post_params)
    @instrument_menu_selection = Instrument.menu_selection
    unless @ensemble_primary.save
      Rails.logger.error("Save on primary failed -- #{@ensemble_primary.error.full_messages}")
      raise e
    end
    num_mmr, num_prearranged = EnsemblePrimary.parse_chamber_music_choice(@ensemble_primary.chamber_ensemble_choice)
    num_mmr.times.each{|i| MmrChamber.create!(:ensemble_primary_id => @ensemble_primary.id)}
    num_prearranged.times.each{|i| PrearrangedChamber.create!(:ensemble_primary_id => @ensemble_primary.id)}
    unless @ensemble_primary.prearranged_chambers.empty?
      pc = @ensemble_primary.prearranged_chambers.first
      pc.instrument_id = @ensemble_primary.registration.instrument_id
      pc.save!
    end
    flash[:ensemble_primary_id] = @ensemble_primary.id
  end

  def chamber_elective
    @ensemble_primary = EnsemblePrimary.find(params[:ensemble_primary][:id])
    
    if params[:ensemble_primary][:mmr_chambers_attributes]
      params[:ensemble_primary][:mmr_chambers_attributes].values.each do |h| 
        raise "upate error" unless MmrChamber.find(h["id"].to_i).update_attributes(h)
      end
    end

    if params[:ensemble_primary][:prearranged_chambers_attributes]
      params[:ensemble_primary][:prearranged_chambers_attributes].values.each do |h| 
        raise "upate error" unless PrearrangedChamber.find(h["id"].to_i).update_attributes(h)
      end
    end

    raise "Problem with save" unless @ensemble_primary.update_attributes(post_params)

    @ensemble_primary = EnsemblePrimary.find(flash[:ensemble_primary_id])
    @electives = Elective.all
    flash[:ensemble_primary_id] = @ensemble_primary.id
  end
      
  def elective_evaluation
    @ensemble_primary = EnsemblePrimary.find(flash[:ensemble_primary_id])
    id_keys = params.keys.select{|k| k =~ /^id_\d+$/}.reject{|k| params[k].empty?}
    @ensemble_primary.ensemble_primary_elective_ranks.each{|x|x.destroy}
    id_keys.each do |id_key|
      elective_id = id_key.split("_")[1].to_i
      if (elective_id == 0)
        raise "No zero ID for me"
      end
      rank = params[id_key].to_i
      instrument_id = params["instrument_id_#{elective_id}"].to_i
      EnsemblePrimaryElectiveRank.create(:ensemble_primary_id => @ensemble_primary.id, 
                                         :elective_id => elective_id, 
                                         :instrument_id => instrument_id,
                                         :rank => rank)
    end
    @ensemble_primary = EnsemblePrimary.find(flash[:ensemble_primary_id])

    # NOTE -- this gets rid of all evaluations then creates new empty ones.
    # Not appropriate for edit situations!
    @ensemble_primary.evaluations.each{|e|e.destroy}
    Rails.logger.warn("Needed: #{@ensemble_primary.need_eval_for.length}")
    @ensemble_primary.need_eval_for.each do |iid| 
      Evaluation.create!(:ensemble_primary_id => @ensemble_primary.id,
                         :instrument_id => iid,
                         :type => Instrument.find(iid).instrumental? ? "InstrumentalEvaluation" : "VocalEvaluation")
    end

    @ensemble_primary = EnsemblePrimary.find(flash[:ensemble_primary_id])
    flash[:ensemble_primary_id] = @ensemble_primary.id
  end

  def evaluation_summary
    @ensemble_primary = EnsemblePrimary.find(flash[:ensemble_primary_id])
    @params = params
    if params[:ensemble_primary][:evaluations_attributes]
      params[:ensemble_primary][:evaluations_attributes].values.each do |h| 
        raise "upate error" unless Evaluation.find(h["id"].to_i).update_attributes(h)
      end
    end
    @ensemble_primary = EnsemblePrimary.find(flash[:ensemble_primary_id])
    flash[:ensemble_primary_id] = @ensemble_primary.id
  end

  private

  def post_params
    params.require(:ensemble_primary).permit(
                                             :registration_id,
                                             :primary_instrument_id,
                                             :large_ensemble_choice,
                                             :chamber_ensemble_choice,
                                             :ack_no_morning_ensemble,
                                             :want_sing_in_chorus,
                                             :want_percussion_in_band,
                                             :mmr_chambers,
                                             :prearranged_chambers
                                             )

  end
end

