class AddPolymorphicAssociationToShipping < ActiveRecord::Migration
  def change
    add_column :shippings, :shippable_id, :integer
    add_column :shippings, :shippable_type, :string
  end
end
