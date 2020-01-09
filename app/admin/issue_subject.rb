ActiveAdmin.register IssueSubject do
  menu parent: "Settings", if: -> { current_user.admin? }

  config.sort_order = 'order_asc'

  permit_params :title, :order

end
