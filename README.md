This extension will add a CSV export button to the admin orders page that allows the user to export order information.

To install, add to Gemfile:

	gem 'shipping_csv', :git => 'git://github.com/msharp/spree-shipping-csv.git'

And update your bundle:

	bundle update

To alter the output of the CSV file, you can define custom output format in:
    
    {Rails.root}/public/shippingdocs/output_override.json

This allows 3 modes of output:
    
    :order          # 1 line per order
    :line_item      # 1 line per line item
    :per_item       # 1 line per ordered item

Examples are available in this extension.

TODO 
    - more information here about how to customise the output.
    - tests (at least for output format file)
