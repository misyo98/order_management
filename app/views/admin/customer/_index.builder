context.instance_eval do
  id_column
  column :first_name
  column :last_name
  column :email if can?(:edit, Customer)
  column (:shirt) { |customer| span customer.shirt_status[:status], class: customer.shirt_status[:class] }
  column (:jacket) { |customer| span customer.jacket_status[:status], class: customer.jacket_status[:class] }
  column (:trouser) { |customer| span customer.pants_status[:status], class: customer.pants_status[:class] }
  column (:waiscoat) { |customer| span customer.waistcoat_status[:status], class: customer.waistcoat_status[:class] }
  column (:overcoat) { |customer| span customer.overcoat_status[:status], class: customer.overcoat_status[:class] }
  column (:chino) { |customer| span customer.chinos_status[:status], class: customer.chinos_status[:class] }
  column :created_at
  column(:author) { |customer| customer.profile ? customer.profile.author_name : span('n/a', class: 'label label-default') }
  column(:acquisition_channel) { |customer| customer.acquisition_channel || span('n/a', class: 'label label-default') }
  actions defaults: true
end
