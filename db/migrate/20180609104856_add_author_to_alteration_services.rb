class AddAuthorToAlterationServices < ActiveRecord::Migration
  def change
    add_reference :alteration_services, :author, index: true
  end
end
