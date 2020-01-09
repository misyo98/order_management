class SalesLocation < ActiveRecord::Base

  def self.look_by_name(name)
    find_by(arel_table[:name].matches("%#{name}%"))
  end
end
