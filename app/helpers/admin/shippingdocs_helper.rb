module Admin::ShippingdocsHelper

    def csv_header_row
        override = override_json
        if override
           override['csv_header_row']
        else
            [
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
        end
    end

    def csv_order_rows(order)
        override = override_json
        
        if override
            resp = []
            
            if override['output_mode'] =~ /^(order|line_item|per_item)$/
                output_mode = override['output_mode'].to_sym 
            else
                output_mode = :order
            end

            if output_mode == :order
                row = []
                override['csv_order_row'].each {|field| row << eval(field)}
                resp << row
            end

            if output_mode == :line_item 
                for item in order.line_items do 
                    row = []
                    override['csv_line_item_row'].each {|field| row << eval(field)}
                    resp << row
                end
            end

            if output_mode == :per_item 
                for item in order.line_items do 
                    rows = []
                    item.quantity.times do
                        row = [] 
                        override['csv_per_item_row'].each {|field| row << eval(field)}
                        rows << row
                    end
                    resp << rows
                end
            end

            return resp
        else
            [[
                order.number, 
                order.completed_at, 
                order.total, 
                order.bill_address.firstname, 
                order.bill_address.lastname, 
                order.bill_address.address1, 
                order.bill_address.address2, 
                order.bill_address.city,
                get_bill_state(order),
                order.bill_address.zipcode,
                order.ship_address.firstname, 
                order.ship_address.lastname, 
                order.ship_address.address1, 
                order.ship_address.address2, 
                order.ship_address.city ,
                get_ship_state(order),
                order.ship_address.zipcode, 
                shipment_weight(order), 
                order.email, 
                order.payment_state, 
                order.shipment_state, 
                order.special_instructions, 
                ordered_items(order)
            ]]
        end
    end

    def shipment_weight(order)
        weight = 0
        order.line_items.reject{|i|i.variant.weight.nil?}.each do |item|
            weight += item.variant.weight
        end
        weight
    end

    def ordered_items(order)
        items = ""
        for item in order.line_items do 
            items << "#{item.variant.sku} #{item.variant.product.name} #{item.variant.options_text} (#{item.quantity})
"             
        end
        items
    end

    def override_json
        overrider = "#{Rails.root}/public/shippingdocs/output_override.json"
        if FileTest.exists?(overrider)
            JSON.parse(File.read(overrider))
        else
            nil
        end 
    end

    def get_ship_state(order)
        State.find(:first, :conditions => { :id => order.ship_address.state_id}).abbr
    end

    def get_bill_state(order)
        State.find(:first, :conditions => { :id => order.bill_address.state_id}).abbr
    end

end
