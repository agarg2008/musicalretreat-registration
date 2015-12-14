====================================
To convert to a new year assuming you were just on the host:
  *   Update any instruments (i.e. intruments you can register for, not faculty) in the DB
  *   Put the new charges in charges.yaml    NOTE, YOU REALLY HAVE TO DO THIS, EVEN IF THE CHARGES
      ARE THE SAME, OTHERWISE YOU GET AN OBSCURE ERROR ON RENDERING THE REGISTRATION FORM
  *   Reset the state of any closed instruments (this is a bit in the DB) -- historically we haven't actually closed instruments,
	    so this probably won't amount to anything
  *  Look at the registration dates in reg_dates.rb -- these should stay the same, but who knows?
  *  Advance the year in year.rb
  *  Look at the early invitees in app/controllers/registration_gating.rb to see if these are really the right people.
     These are the people who will be let in prior to the 1st
  *  Note the flags in the registration_controller.  Probably registration and payments are both forced closed.  The logic is:
       *  at the end of a cycle (i.e. June) both are forced closed, and nobody can register or pay
       *  during the test period, set both to false. This will let early invitees both register and pay, but the fact that 
             the current year < registration year will block everybody else
       *  at midnight on the 1st, registration should automatically open to everybody
       *  when Tricia calls it closed, force registration closed, but keep payments open
       *  after the payment deadline (June 1??) force payments closed too, and we're reset for next year!


===========================================================
Events
   Various things get dumped to the events table (password changes, emails sent)
   http://registration.musicalretreat.org/admin/show_events
   http://registration.musicalretreat.org/admin/delete_events

===========================================================
Emails we can send, and how to send them.

Configuration is in environment.rb.   Remember this if you change the password for registration-mailer!

->  Controller (registration controller in case of things like payment confirmation, admin controller for bulk mailings) 
->  initiates the process with static method calls to RegistrationMailer
->     *  the parameters like email addresses, subject are in the registration_mailer class
->     *  the templates are in app/views/registration_mailer, and there are two per mail type

1. Sending all registration invitations
     *  The entry point is admin/send_all_invitations
     *  It keys off a table invitees.  You need either to empty it out, or fill it with your email addresses.  If 
	it's empty, it will be populated with the emails of all users whose emails have not bounced.
     *  It will not generate any output, but it uses the Event model, so a good idea to delete events first then keep an eye on the events
     *  The two separate templates are reg_invitation_with_new_password, and reg_invitation_without_new_password

     =>  As an initial test, put your email only in the invitees list, and browse to admin/send_all_invitations
     =>  Since invitees is active record, easiest to do it from the console


  => there's still some residual ugliness.  Bluehost kills on exceeding 350 emails per hour, so the first
  =>  call failed.  Semi-fixed it by putting a sent field in the invitee record.  Then if it limits out
  =>  the first time you can run it again.  It's possible there's an off-by-one error because the one 
  =>  that causes the error might be listed as sent.  Much better next time to restore the limit, which 
  =>  along with the sent flag should fix everything.

  NOTE 12/2011 -- Gennie sent a template that does not distinguish between existing and new users.
  So the single template will be reg_invitation, and the others will be retired.

============

2.  Payment confirmation -- this is done when Tricia records a payment on the site.
     *  Template is confirm_payment

3.  Balance reminders
     * the entry point is admin/send_balance_reminder_email
     * automatically sends to all registrations with balance > 0
     * template is deliver_balance_reminder
     * you can test ahead of time with the variable test_emails defined within the method send_balance_reminder_email

4. Send a registration confirmation
     * this is done automatically on registration, through registration controller
     * template is confirm_registration

===========================================================
Testing the registraiton system

How it works:
1.  The list of testers is in registraiton_controller in a class variable @@EARLY_INVITEES
2.  Prior to Jan 1, they need to log in (button on lower right, currently) and the system will recognize them
3.  Right now the email is sent manually 