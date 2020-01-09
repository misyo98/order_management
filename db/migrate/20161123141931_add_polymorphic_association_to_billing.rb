class AddPolymorphicAssociationToBilling < ActiveRecord::Migration
  def change
    add_column :billings, :billable_id, :integer
    add_column :billings, :billable_type, :string
  end
end
