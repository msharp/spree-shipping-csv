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
            "Order",
            "DateCompleted",
            "ProductSKU",
            "ProductName",
            "Quantity",
            "Units",
            "Price",
            "SubTotal",
            "Refund",
            "RefundReason",
            "CartStatus",
            "WineBrand",
            "ThirdPartyStore",
            "ShipFirstName",
            "ShipLastName",
            "ShipCompany",
            "ShipAddress",
            "ShipAddress2",
            "ShipCity",
            "ShipState",
            "ShipZip",
            "ShipPhone",
            "ShipEmail"
        ]
      
        # data rows
        @orders.each do |order|
        
            for item in order.line_items do 
                
                csv_line = [
                    order.number, 
                    order.completed_at,
                    item.variant.sku,
                    item.variant.product.name,
                    "1", # 1 line in output per item ordered,
                    "6", # wineplus hack - all products contain 6 units,
                    item.variant.price,
                    item.variant.price, # 'subtotal',
                    "",
                    "",
                    "Complete",
                    item.variant.product.name,
                    "WinePlus",
                    order.ship_address.firstname, 
                    order.ship_address.lastname, 
                    "",
                    order.ship_address.address1, 
                    order.ship_address.address2, 
                    order.ship_address.city ,
                    State.find(:first, :conditions => { :id => order.ship_address.state_id}).abbr, 
                    order.ship_address.zipcode, 
                    "",
                    order.email
                ]


                item.quantity.times do
                    csv << csv_line
                end
            end     
        end
    end

    # send it to the browsah
    send_data csv_string,
            :type => 'text/csv; charset=iso-8859-1; header=present',
            :disposition => "attachment; filename=users.csv"

  end

end

