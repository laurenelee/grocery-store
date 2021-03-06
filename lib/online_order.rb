require 'csv'
require_relative 'order'
require_relative 'customer'

module Grocery
  class OnlineOrder < Order
    attr_reader :customer_id, :status
    @@all_online_orders = []

    def initialize(id, products, customer, status = :pending)
      super(id, products)
      @customer = Grocery::Customer.find(customer)
      @customer_id = customer
      @status = status.to_sym
    end #initialize

    # def customer(customer_id)
    #   # Customer.find
    # end

    def total
      if super == 0
        return 0
      else
        super + 10
      end
    end

    def add_product(product_name, product_price)
      case @status
      when :pending, :paid
        super(product_name, product_price)
      when :complete, :processing, :shipped
        raise ArgumentError.new("Error: Cannot add if #{@status}.")
      end
    end


    def self.all
      if @@all_online_orders.length > 0
        return @@all_online_orders
      end
      # not using super b/c new csv and taking in more arguments (we don't want anything from Order.all from Order file) we want ALL of the online_orders
      CSV.open("support/online_orders.csv", 'r').each do |line|
        id = line[0].to_i
        customer_id = line[2].to_i
        status = line[3].to_sym
        # playing with .sub!
        # line[1] = line[1].gsub! ';', ','
        # line[1] = line[1].gsub! ':', '=>'
        products = {}
        products_arr = line[1].split(';')
        products_arr.each do |item|
          product_price = item.split(':')
          products[product_price[0]] = product_price[1].to_f
        end


        @@all_online_orders << self.new(id, products, customer_id, status)

      end # each loop
      return @@all_online_orders
    end #self.all

    def self.find(id)
      # use super?
      # super
      # if id > all.length
      #   raise ArgumentError.new("Error: #{id} does not exist")
      # end
      if id > @@all_online_orders.length
        raise ArgumentError.new("That #{id} doesn't exist")
      end

      all.each do |order|
        if id == order.id
          return order
        end
      end

    end #self.find(id)

    def self.find_by_customer(customer_id)
      if customer_id > @@all_online_orders.length
        raise ArgumentError.new("Sorry, customer #{customer_id} doesn't exist")
      end
      customers_orders = []
      all.each do |order|
        if order.customer_id == customer_id
          customers_orders << order
        end
      end
      return customers_orders
    end
    # puts OnlineOrder.find_by_customer(120)

  end # Customer class
end # Grocery module
#
# Why is it useful to put classes inside modules? 	|   Absolutely! Organizationally it allowed me to make sense of what the grocery module had within it. As a namespace, it helps to map out the relationships and think about how to inherit/pass behaviors to other classes and DRY up the code.	|
# |   What is accomplished with `raise ArgumentError`? 	|  With  ArgumentErrors, you are able to predict the potential and possible errors. They help me double check that my code is doing exactly what I expect it to do.  |
#   |   Why do you think we made the `.all` & `.find` methods class methods?  Why not instance methods?	| It made sense to use class methods as opposed to instance methods because they are called on the class itself as opposed to just one particular instance of an order.  	|
#     |   Why does it make sense to use inheritance for the online order?  | The online order already had customer information so it made sense to inherit that onto the online order and simply build from code we had already written.  |
#     |   Did the presence of automated tests change the way you thought about the problem? How? | Yes and in a really fascinating way. I had such a better understanding of what my code was trying to execute because of the tests I wrote beforehand.  |
#
