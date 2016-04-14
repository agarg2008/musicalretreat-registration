class RegistrationMailer < ActionMailer::Base

  default :from => "registrar@musicalretreat.org", 
          :reply_to => "registrar@musicalretreat.org", 
          :cc => "online-registration@musicalretreat.org"

  def test(email)
    mail(:from => "online-registration@musicalretreat.org", :to => email, :subject => "New Message, just checking this peram").deliver!
  end

  # Bulk email inviting to register
  def invitation(user)
    @first_name = user.first_name
    @year = Year.this_year
    mail(:from => "online-registration@musicalretreat.org", :to => user.email, :subject=> "MMR #{Year.this_year} Registration").deliver!
    Event.log("Sent invitation email to #{user.id}")
  end

  def self_eval_invitation(user)
    @first_name = user.first_name
    @year = Year.this_year
    mail(:from => "online-registration@musicalretreat.org", 
         :to => user.email, 
         :subject=> "MMR #{Year.this_year} Ensemble Selection and Self Evaluation").deliver!
    Event.log("Sent invitation email to #{user.id}")
  end

  def self_eval_reminder(user)
    @first_name = user.first_name
    @year = Year.this_year
    mail(:from => "online-registration@musicalretreat.org", 
         :to => user.email, 
         :subject=> "REMINDER: Fill out your MMR #{Year.this_year} Ensemble Selection and Self Evaluation").deliver!
    Event.log("Sent invitation email to #{user.id}")
  end

  def early_invitation(email)
    mail(:to => email, :subject => "Please register early and test the registration system").deliver!
  end
    
  # From the reg invitation button on admin.  This either creates or uses a password
  def invitation_with_new_password(email, password)
    @email = email
    @password = password
    mail(:to => email, :subject => "Come register for MMR #{Year.this_year}").deliver!
  end

  # After successfull form submit
  def confirm_registration(registration)
    @name = "#{registration.first_name} #{registration.last_name}"
    @cart = registration.cart
    @payment = -@cart.payment_net
    @balance = @cart.balance
    mail(:to => registration.user.email, :subject => "MMR Registration Confirmation").deliver!
    Event.log("Sent registration confirmation email to #{registration.user.email}")
  end

  def confirm_payment(payment)
    @name = "#{payment.registration.first_name} #{payment.registration.last_name}"
    @payment = payment
    mail(:to => payment.registration.user.email, :subject => "MMR Payment Confirmation").deliver!
    Event.log("Sent payment confirmation email to #{payment.registration.user.email}")
  end

  def new_account(email, password)
    @email = email
    @password = password
    mail(:to => email, :subject => "MMR New Account or Password Reset").deliver!
    Event.log("Sent new account or password reset to #{@email} and #{@password}")
  end

  def balance_reminder(registration)
    @name = registration.display_name
    @balance = registration.balance
    mail(:to => registration.email, :subject => 'MMR Balance Due Reminber').deliver!
  end

  def eval_reminder(registration)
    @name = registration.display_name
    mail(:to => registration.email, :subject => 'MMR Ensemble Choice and Self-Evaluation Reminber').deliver!
  end

end
