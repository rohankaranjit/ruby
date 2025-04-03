require 'date'  # Required for date parsing

# Order class
class Order
  attr_accessor :customer, :quantity, :order_date

  def initialize(customer, quantity, order_date)
    @customer = customer  # "VIP" or "Regular"
    @quantity = quantity
    @order_date = Date.parse(order_date)  # Convert to Date object
  end
end

# Product class
class Product
  attr_accessor :name, :stock, :reorder_point, :batch_number, :expiry_date

  def initialize(name, stock, reorder_point, batch_number, expiry_date)
    @name = name
    @stock = stock
    @reorder_point = reorder_point
    @batch_number = batch_number
    @expiry_date = Date.parse(expiry_date)  # Convert to Date object
    @sales_history = []  # Track sales history
    @orders = []         # Track orders
    @inventory = []      # Inventory for batch tracking
  end

  # Add an order to the orders list
  def add_order(order)
    @orders << order
  end

  # Allocate stock to customer orders using FIFO (Inventory Valuation)
  def allocated_stock
    # Sort orders by customer type (VIP first) and order date
    sorted_orders = @orders.sort_by { |order| [order.customer == "VIP" ? 0 : 1, order.order_date] }

    sorted_orders.each do |order|
      if @stock >= order.quantity
        @stock -= order.quantity
        puts "✅ Allocated #{order.quantity} units to #{order.customer}. Stock left: #{@stock}"
      else
        puts "❌ Not enough stock for #{order.customer}. Only #{@stock} left."
      end
    end
  end

  # Check if stock is below reorder point and needs replenishment
  def check_reorder
    if @stock < @reorder_point
      puts "⚠️ Stock for #{@name} is below reorder point. Please reorder. Only #{@stock} left."
    else
      puts "✅ Stock for #{@name} is sufficient. #{@stock} in stock."
    end
  end

  # Calculate buffer stock (extra stock to handle unexpected demand)
  def buffer_stock
    order_quantity = (@reorder_point - @stock) * 2
    puts "📦 Buffer stock for #{@name} is #{order_quantity}"
  end

  # Record sales and reduce stock
  def record_sales(quantity)
    if quantity > @stock
      puts "❌ Not enough stock for #{@name}. Only #{@stock} left."
      return
    end

    @sales_history << quantity
    @stock -= quantity

    puts "📉 Sold #{quantity} units of #{@name}. Remaining stock: #{@stock}"
    check_reorder
  end

  # Place an order based on average sales and reorder point
  def place_order
    avg_sales = @sales_history.empty? ? 1 : @sales_history.sum / @sales_history.size.to_f
    lead_time = 7  # Set a fixed lead time (e.g., 7 days)
    order_quantity = (avg_sales * lead_time).to_i
    order_quantity = [order_quantity, @reorder_point].max

    puts "🛒 Placing order for #{order_quantity} units of #{@name}"
  end

  # FIFO Inventory Valuation
  def inventory_valuation
    puts "🔢 Calculating Inventory Valuation for #{@name} using FIFO method:"
    
    # FIFO logic (First In, First Out)
    @inventory.each do |batch|
      puts "Batch ##{batch[:batch_number]} (Expiry Date: #{batch[:expiry_date]}): #{batch[:quantity]} units"
    end
  end

  # Batch Tracking
  def add_batch(batch_number, quantity, expiry_date)
    @inventory << { batch_number: batch_number, quantity: quantity, expiry_date: Date.parse(expiry_date) }
    puts "📦 Added Batch ##{batch_number} (Quantity: #{quantity}, Expiry: #{expiry_date})"
  end

  def track_batch
    puts "Tracking batches for #{@name}:"
    @inventory.each do |batch|
      puts "Batch ##{batch[:batch_number]}: Expiry Date: #{batch[:expiry_date]}, Quantity: #{batch[:quantity]}"
    end
  end
end

# --- Usage Example ---
# Create Product with initial batch tracking
product = Product.new("Ketchup", 50, 20, "B001", "2025-12-31")  # 50 units in stock, reorder point is 20

# Add some batches
product.add_batch("B002", 30, "2026-01-01")
product.add_batch("B003", 20, "2025-06-30")

# Record Sales
product.record_sales(10)  # Sold 10 units of Laptop

# Create Orders
order1 = Order.new("VIP", 4, "2025-04-03")
order2 = Order.new("Regular", 3, "2025-04-02")
order3 = Order.new("VIP", 5, "2025-04-01")

# Add Orders to Product
product.add_order(order1)
product.add_order(order2)
product.add_order(order3)

# Allocate Stock to Orders
product.allocated_stock

# Check Reorder Point (will trigger because stock < reorder_point)
product.check_reorder

# Calculate Buffer Stock
product.buffer_stock

# Place an order to replenish stock
product.place_order

# Perform Inventory Valuation (FIFO)
product.inventory_valuation

# Track Batches
product.track_batch
