############################################################################################
#  This is the logic for allowing registration and payment (used to light up or shut down
#  buttons in the index view, and the new and pay methods should also check this.  Logic is:
#    -- the variables @@FORCE_REGISTRATION_CLOSED  and @@FORCE_PAYMENT_CLOSED are set manually
#    -- if either is true, registration or payment is impossible
#    -- if the variables are false, the controller checks whether current date < registration date.
#            if it is (not time yet), the session email is checked against an early test list
#    -- this is communicated only by the methods can_register  and can_pay

module RegistrationGating

  @@FORCE_REGISTRATION_CLOSED = false
  @@FORCE_PAYMENT_CLOSED = false

  @@EARLY_INVITEES = %w{
      mtnester@seanet.com
      susanstpleslie@gmail.com
      warmsun06@gmail.com
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
      suecdc@msn.com
}

  #  Controls messaging on the index page banner, also used do define can_register and can_pay
  def status
    return :open
    return :closed if @@FORCE_REGISTRATION_CLOSED
    return :open if Time.now > RegDates.registration_opens
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

end

