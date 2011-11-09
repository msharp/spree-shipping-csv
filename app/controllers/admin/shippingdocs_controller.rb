require 'fastercsv'

class Admin::ShippingdocsController < Admin::BaseController
  def index

    # TODO _ parse date according to locale setting
      
    if params[:start] == "" then
      @dateStart = DateTime.strptime('1980/1/1', "%Y/%m/%d")
    else
      @dateStart = DateTime.strptime(params[:start], "%Y/%m/%d")
    end

    if params[:end] == "" then
      @dateEnd = DateTime.strptime('3000/1/1', "%Y/%m/%d")
    else
      @dateEnd = DateTime.strptime(params[:end], "%Y/%m/%d")
    end
    
    @orders = Order.find(:all, :conditions => { :created_at => @dateStart..@dateEnd, :state => 'complete' })

    csv_string = FasterCSV.generate do |csv|
        # header row
        csv << [
            "order_number", 
            "order_date", 
            "order_total", 
            "billing_first_name", 
            "billing_last_name", 
            "billing_address_1", 
            "billing_address_2", 
            "billing_city", 
            "billing_state", 
            "billing_zip",
            "shipping_first_name", 
            "shipping_last_name", 
            "shipping_address_1", 
            "shipping_address_2", 
            "shipping_city", 
            "shipping_state",
            "shipping_zip", 
            "weight", 
            "email", 
            "payment_state", 
            "shipment_state", 
            "special_instructions", 
            "products_ordered" 
        ]
      
      # data rows
      @orders.each do |order|

        if order.state == 'in_progress' then
        else
          @shipmentWeight = 0
          order.line_items.each do |item|
            if item.variant.weight.nil? then
            else
              @shipmentWeight += item.variant.weight
            end
          end
          csv << [
              order.number, 
              order.completed_at, 
              order.total, 
              order.bill_address.firstname, 
              order.bill_address.lastname, 
              order.bill_address.address1, 
              order.bill_address.address2, 
              order.bill_address.city,
              State.find(:first, :conditions => { :id =>order.bill_address.state_id}).abbr, 
              order.bill_address.zipcode,
              order.ship_address.firstname, 
              order.ship_address.lastname, 
              order.ship_address.address1, 
              order.ship_address.address2, 
              order.ship_address.city ,
              State.find(:first, :conditions => { :id => order.ship_address.state_id}).abbr, 
              order.ship_address.zipcode, 
              @shipmentWeight, 
              order.email, 
              order.payment_state, 
              order.shipment_state, 
              order.special_instructions, 
              ordered_items(order)
          ]
            
        end

       end
    end

      # send it to the browsah
      send_data csv_string,
            :type => 'text/csv; charset=iso-8859-1; header=present',
            :disposition => "attachment; filename=users.csv"
  end

  def ordered_items(order)
    items = ""
    for item in order.line_items do 
      items << "#{item.variant.sku} #{item.variant.product.name} #{item.variant.options_text} (#{item.quantity})
"             
    end
    items
  end

end

