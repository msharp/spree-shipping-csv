require 'fastercsv'

class Admin::ShippingdocsController < Admin::BaseController
  include ActionView::Helpers::TextHelper
  def index

    date_end = Time.new
    date_start = date_end - (60 * 24 * 7)

    # parse date according to locale setting
    if !params[:start].blank?
      date_start = Time.zone.parse(params[:start]).beginning_of_day rescue ""
    end

    if !params[:end].blank?
        date_end = Time.zone.parse(params[:end]).end_of_day rescue ""
    end
   
    @orders = Order.find(:all, :conditions => { :completed_at => date_start..date_end, :state => 'complete' })

    csv_string = FasterCSV.generate({:force_quotes => true}) do |csv|
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
                ].map{|s| s.is_a?(String) ? s[0..39] : s}

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

