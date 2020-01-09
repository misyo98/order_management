ActiveAdmin.register Refund do
  decorate_with RefundDecorator

  menu parent: 'Accountings', if: -> { can? :index, Refund }
  actions :show, :index
  config.filters = false

  index do
    id_column
    column :order_number
    column(:line_item_id) { |refund| refund.line_item_id }
    column :customer_full_name
    column :shipping_country
    column :product_title
    column :refund_amount
    column :refund_currency
    column :refund_reason
    column :refund_date
    column :order_date
    column :list_price
    column :paid_price
    column :vat_export_status
    actions
  end

  csv do
    column('ID', humanize_name: false) { |refund| refund.id }
    column('Order Number', humanize_name: false) { |refund| refund.order_number }
    column('Line Item', humanize_name: false) { |refund| refund.line_item_id }
    column('Customer Full Name', humanize_name: false) { |refund| refund.customer_full_name }
    column('Shipping Country', humanize_name: false) { |refund| refund.shipping_country }
    column('Product Title', humanize_name: false) { |refund| refund.product_title }
    column('Refund Amount', humanize_name: false) { |refund| refund.refund_amount }
    column('Refund Currency', humanize_name: false) { |refund| refund.refund_currency }
    column('Refund Reason', humanize_name: false) { |refund| refund.refund_reason }
    column('Refund Date', humanize_name: false) { |refund| refund.refund_date }
    column('Order Date', humanize_name: false) { |refund| refund.order_date }
    column('List Price', humanize_name: false) { |refund| refund.list_price }
    column('Paid Price', humanize_name: false) { |refund| refund.paid_price }
    column('VAT Export Status', humanize_name: false) { |refund| refund.vat_export_status }
  end

  controller do
    def scoped_collection
      super.includes(line_item: { order: [:billing, :shipping] })
    end
  end
end
