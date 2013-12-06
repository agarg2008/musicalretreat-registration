class RegistrationController < ApplicationController
  
  before_filter :authorize, :only 	=> [ :new, :view, :edit, :commit, :confirm, :test, :payment ]

  ############################################################################################
  #  This is the logic for allowing registration and payment (used to light up or shut down
  #  buttons in the index view, and the new and pay methods should also check this.  Logic is:
  #    -- the variables @@FORCE_REGISTRATION_CLOSED  and @@FORCE_PAYMENT_CLOSED are set manually
  #    -- if either is true, registration or payment is impossible
  #    -- if the variables are false, the controller checks whether current date < registration date.
  #            if it is (not time yet), the session email is checked against an early test list
  #    -- this is communicated only by the methods can_register  and can_pay

  @@FORCE_REGISTRATION_CLOSED = true
  @@FORCE_PAYMENT_CLOSED = true

  @@EARLY_INVITEES = %w{
      mtnester@seanet.com
      susanstpleslie@gmail.com
      warmsun06@gmail.com
      dot.rust@gmail.com
      jessicacroysdale@yahoo.com
      doug@conicwave.net
      jenny2247@hotmail.co.uk
      brantallen@earthlink.net
      conniebrennand@hotmail.com
      donamac2011@gmail.com
      genniewinkler@mac.com
      gorakr@comcast.net
      gpurkhiser@msn.com
      groupw@rocketwire.net 
      hanks@pobox.com 
      ivoryharp@comcast.net
      jessicacroysdale@yahoo.com
      june.hiratsuka@comcast.net
      ksunmark@yahoo.com
      lhpilcher@frontier.com
      rbhudson@comcast.net
      rkremers@earthlink.net
      rm.thompson@comcast.net
      rumeimistry@yahoo.com
      stkeene@mac.com
      szell41534@aol.com
      tricia616@msn.com
      trptplayer@mac.com
      brad@sixteenpenny.net
}

  #  Controls messaging on the index page banner, also used do define can_register and can_pay
  def status
    return :closed if @@FORCE_REGISTRATION_CLOSED
    return :open if Date.today.year.to_s == Year.this_year
    return :premature
  end

  def session_email
    user = session[:user_id] && User.find(session[:user_id])
    return user ? user.email : nil
  end

  def can_register
    return false if status == :closed
    return true if status == :open
    return session_email && @@EARLY_INVITEES.include?(session_email.downcase)
  end

  def can_pay
    return !@@FORCE_PAYMENT_CLOSED
  end

  ############################################################################  

  def index
    @email = session_email
    @status = status
    @can_register = can_register
    @can_pay = can_pay
  end
  
  def begin
    @email = session_email
    @status = status
    @can_register = can_register
  end

  ####################################################
  #  The pattern for new/view/edit is the same:  the call
  #  could come from the admin controller, in which case the 
  #  the user_id (new) or registration_id (view/edit) comes in 
  #  through a parameter.  It could come from the registration 
  #  controller, in which case we get the id from the session.
  #  Also, new and edit will accept the form post.
  #  Note we are using a user_id in all three cases, assuming
  #  the current registration
  
  def new
    if request.post? && params[:registration]
      verify_admin_or_self(params[:registration][:user_id])
      @registration = Registration.new(params[:registration])
      if Registration.find_by_user_id_and_year(@registration.user_id, @registration.year)
        flash[:notice] = "We already have a registration for #{@registration.user.email}"
        redirect_to :action => :index
      elsif @registration.save
        FileMakerContact.setContactID(@registration)
        Event.log("New registration created for #{@registration.user.email}")
        send_confirm_email(@registration)
        if @registration.payment_mode =~ /check/
          flash[:notice] = "New registration successful"
          reg_redirect(:confirm_registration)
        else
          redirect_to :controller => :cc, :action => :depart, :id => @registration.id
        end
      else
        @regform_type = :new
      end
      ## The params[:admin] is a cheap hack to do an end-around the 
      ## the registration closed gating.  It is set from the administration controller for the
      ## "Enter New Registration" functionality.  
    elsif !params[:admin] && !can_register     
      u = User.find(session[:user_id])
      Event.log("Somebody tried to cheat (no login)") unless u
      Event.log("Somebody tried to cheat (#{u.email})") if u
      render :action => :try_again
    else
      user_id = params[:id] || session[:user_id]
      verify_admin_or_self(user_id)
      user = User.find(user_id)
      if user.has_current_registration
        flash[:notice] = "User #{user.email} is already registered"
        reg_redirect
      else
        @registration = Registration.populate(user)
        @regform_type = :new
        render :action => :new
      end
    end
  end
  
  ##########
  
  def view
    user_id = params[:id] || session[:user_id]      
    verify_admin_or_self(user_id)
    @registration = Registration.find_by_user_id_and_year(user_id, Year.this_year)
    if (!@registration)
      flash[:notice] = "No registration found"
      redirect_to :action => :index
    else
      @regform_type = :view
      if session[:reg_form_callback]
        @back_controller = session[:reg_form_callback][0]
        @back_action = session[:reg_form_callback][1]
        session[:reg_form_callback] = nil
      else
        @back_controller = :registration
        @back_action = :index
      end
    end
  end
  
  ##########
  ##  For now we are not allowing users to edit, so all calls must come 
  ##  with an ID, and be administrator validated
  
  def edit
    if request.post? && params[:registration]
      verify_admin_or_self(params[:registration][:user_id])
      reg = User.find(params[:registration][:user_id]).current_registration
      if reg.update_attributes(params[:registration])
        flash[:notice] = "Edit successful"
        reg_redirect(:index)
      else
        flash[:notice] = "Error updating"
        @registration = Registration.new(params[:registration])
        @regform_type = :edit
      end
    else
      user_id = params[:id]    #  No session[:user_id]
      verify_admin_or_self(user_id)
      @registration = User.find(user_id).current_registration
      if @registration
        @regform_type = :edit
      else
        reg_redirect(:index, "No registration to edit")
      end
    end
  end
  
  ##  Helpers for new/edit/view
  
  private
  
  #  Caller may put a controller/action pair in the session -- if so, 
  #  go there.  Otherwise go somewhere in the current controller
  
  def reg_redirect(action = :index, notice = nil)
    flash[:notice] = notice if notice
    if session[:reg_form_callback]
      flash[:notice] = notice if notice
      controller = session[:reg_form_callback][0]
      action = session[:reg_form_callback][1]
      session[:reg_form_callback] = nil
      redirect_to  :controller => controller, :action => action
    else
      redirect_to :action => action
    end
  end
  
  # The calls to new/edit/view should only be made internally -- controllers 
  # should call new_by_session or new_by_id.  However, those internal methods 
  # need to be public, otherwise the instance variables are null in the templates.
  # This won't enforce an internal call, but it will prevent mischief (I hope).
  # By rights this should be a helper and filter, but I couldn't figure out 
  # how to deal with the ID parameter


  def verify_admin_or_self(id_string)
    id = id_string.to_i
    user = User.find_by_id(session[:user_id])
    return true if user && (user.admin || user.id == id)
    raise "ID mismatch -- ID passed in is #{id};  session says #{session[:user_id]};  user is #{user} with ID #{user.id}"
  end
  
  #######################################################
  public

  def payment
    user = User.find(session[:user_id])
    if !user
      flash[:notice] = "Not logged in"
      redirect_to :action => :index
    elsif !user.has_current_registration
      flash[:notice] = "You are not currently registered"
      redirect_to :action => :index
    elsif user.current_registration.balance == 0
      flash[:notice] = "No balance to pay"
      redirect_to :action => :index
    elsif params[:type]
      @registration = Registration.find(params[:id])
      @registration = user.current_registration
      if params[:type] == "deposit"
        @registration.payment_mode = "deposit_cc"
      else 
        @registration.payment_mode = "balance_cc"
      end
      @registration.save!
      redirect_to( :controller => :cc, :action => :depart, :id => @registration.id)
    else
      @registration = user.current_registration
    end
  end

  def confirm_registration
    user = User.find(session[:user_id])
    if user && user.has_current_registration
      @registration = user.most_recent_registration
      @email = user.email
      @cart = @registration.cart
      Event.log("#{user.email} confirmed")
    else
      flash[:notice] = "You do not have a current registration"
      Event.log("#{user.email} tried to confirm but no registration")
      redirect_to :action => "index"
    end
  end
  
  def send_confirm_email(registration)
    #user = User.find(session[:user_id])
    #if user && user.has_current_registration
    #  registration = user.most_recent_registration
      cart = registration.cart
    #email = registration.user.email
      RegistrationMailer.deliver_confirm_registration(registration, -cart.payment_net, cart.balance)
    #end
  end

  #######################################################
  
  def new_password
    session[:original_uri] = url_for(:controller => :registration, :action => :index)
    redirect_to(:controller => :login, :action => :new_password)
  end

  def change_password
    session[:original_uri] = url_for(:controller => :registration, :action => :index)
    redirect_to(:controller => :login, :action => :change_password)
  end
  
  def paper_form
    redirect_to("http://musicalretreat.org/docs/registration.pdf")
  end
  
  def login
    session[:original_uri] = url_for(:controller => :registration, :action => :index)
    session[:login_type] = :normal
    redirect_to(:controller => :login, :action => :login)
  end

  def logout
    session[:original_uri] = url_for(:controller => :registration, :action => :index)
    redirect_to(:controller => :login, :action => :logout)
  end

  def done
    session[:original_uri] = url_for(:controller => :registration, :action => :index)
    redirect_to(:controller => :login, :action => :logout)
  end

  #  Preliminary testing only?
  # def cc_payment
  #   @registration = Registration.find(params[:id])
  #   @payment = @registration.cart.payment
  #   @id = @registration.id
  # end
  #######################################################
  #  Ajax call via observe_form on the reg form
  
  def update_cart
    reg = Registration.new(params[:registration])
    cart = reg.cart 
    render :partial => "cart", :object => cart, :layout => false
  end
end
