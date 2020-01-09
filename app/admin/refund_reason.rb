ActiveAdmin.register RefundReason do
menu parent: 'Settings', if: -> { can? :index, RefundReason }

permit_params :title, :order

end
