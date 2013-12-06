class Cart
  
  attr_reader :charges
  attr_reader :registration
  
  def initialize(registration)
    @registration = registration
    @charges = {}
  end

  def payment_mode
    @registration.payment_mode
  end

  def display_cc
    payment_mode =~ /cc/ && !@registration.id
  end

  def charge_items
  	charges.values.sort {|ci1, ci2| ci2.total <=> ci1.total}
  end
  
  def add_charge(charge_name)
        current_charge = @charges[charge.name]
        if current_charge
          current_charge.increment_quantity
        else
          current_charge = ChargeItem.new(charge_name, Cart.price(charge_name), 1)
          @charges[charge_name] = current_charge
        end
    end
    
    def remove_charge(charge_name)
    	current_charge = @charges[charge_name]
    	if current_charge
    		current_charge.decrement_quantity
    		if current_charge.empty
    			@charges.delete(charge_name)
    		end
    	end
   end
   
   def set_quantity(charge_name, howmany)
     	if howmany <= 0
     		@charges.delete(charge_name)
     	else
     		current_charge = @charges[charge_name]
     		if current_charge
     			current_charge.quantity = howmany
     		else
     			@charges[charge_name] = ChargeItem.new(charge_name, Cart.price(charge_name), howmany)
     		end
     	end
    end
    
    def install_charge(charge_name, amount)
    	@charges[charge_name] = ChargeItem.new(charge_name, amount, 1)
    end

    def total
      @charges.values.sum { |charge| charge.total }
    end
    
    def size
      @charges.size
    end

    #######################################################
    #  Credit card charge, balance, and payment promised.  
    #  Payment modes are deposit_check, balance_check, deposit_cc, balance_cc
    #  Payment promised (payment) is either deposit, or balance, plus CC fees


    def self.cc_charge(net)
      cc_fixed = Charge.charge_for("Credit Card Flat Rate").to_f
      cc_variable = Charge.charge_for("Credit Card Percentage").to_f / 100.0
      amount = cc_fixed + (net * cc_variable)
      ((amount*100.0).truncate)/100.0
    end
      
    def credit_card_charge
      return 0.0 if payment_mode =~ /check/
      cc_fixed = Charge.charge_for("Credit Card Flat Rate").to_f
      cc_variable = Charge.charge_for("Credit Card Percentage").to_f / 100.0
      if payment_mode == "deposit_cc"
        amount = deposit
      elsif payment_mode == "balance_cc"
        amount = balance
      else
        raise "Bad payment mode #{payment_mode}"
      end
      Cart.cc_charge(amount)
    end

    def deposit
      [Charge.charge_for("Deposit").to_f, total].min
    end

  #  Payment amount is the amount that goes to the payment processor:  either deposit or balance 
  #  as was selected by payment mode, with credit card charge added in.  

    # Payment including credit card fees (this goes on registration page cart sidebar)
    def payment
      return (deposit + credit_card_charge) if (payment_mode =~ /deposit/)
      return (balance + credit_card_charge) if (payment_mode =~ /balance/)
      raise "Bad payment mode #{payment_mode}"
    end

    # Payment net of credit card fees (this goes in confirm email on confirm page)
    def payment_net
      return deposit if (payment_mode =~ /deposit/)
      return total if (payment_mode =~ /balance/)
      raise "Bad payment mode #{payment_mode}"
    end

    def balance_assuming_payment
      total - payment_net
    end

    def balance
      balance_assuming_payment
    end

    private

  	def get_quantity(charge_name)
  		current_charge = charges[charge_name]
  		current_charge ? current_charge.quantity : 0
  	end

	def self.price(name)  		
          Charge.charge_for(name) || raise("Tried to find price of #{name} and it wasn't there")
 	end
end
