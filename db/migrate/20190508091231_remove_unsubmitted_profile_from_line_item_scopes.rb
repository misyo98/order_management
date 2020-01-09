class RemoveUnsubmittedProfileFromLineItemScopes < ActiveRecord::Migration
  def up
    LineItemScope.find_each do |scope|
      scope.update(states: scope.states - ['unsubmitted_profile'])
    end
  end

  def down
  end
end
