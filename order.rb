class Order
  attr_accessor :customer, :amount, :status

  def initialize(customer, amount)
    @customer = customer
    @amount = amount
    @status = "pending"
  end

  def process
    return puts "Credit limit exceeded! Approval needed." if customer.exceeds_credit?(amount)

    discount = apply_discount
    tax = calculate_tax
    warehouse = route_order

    puts "Discount: Rs#{discount}, Tax: Rs#{tax}, Routed to: #{warehouse}"
    puts "Total amount is #{amount + discount + tax}"

    if needs_approval?
      puts "Order sent for approval!"
      @status = "pending_approval"
    else
      puts "Order approved!"
      @status = "approved"
    end
  end

  private

  def apply_discount
    amount > 500 ? amount * 0.1 : amount * 0.05
  end

  def calculate_tax
    amount * 0.07  # Example: 7% tax
  end

  def route_order
    "Main Warehouse"
  end

  def needs_approval?
    amount > 1000
  end
end

class Customer
  attr_accessor :name, :credit_limit, :balance

  def initialize(name, credit_limit, balance)
    @name = name
    @credit_limit = credit_limit
    @balance = balance
  end

  def exceeds_credit?(order_amount)
    balance + order_amount > credit_limit
  end
end

customer = Customer.new("Rohan", 1000, 600)
order = Order.new(customer, 100)

order.process
puts "Final Status: #{order.status}"
