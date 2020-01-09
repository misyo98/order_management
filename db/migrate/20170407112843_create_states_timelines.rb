class CreateStatesTimelines < ActiveRecord::Migration
  def up
    create_table :states_timelines do |t|
      t.string :state, null: false, index: true
      t.string :from_event
      t.integer :allowed_time_uk
      t.integer :allowed_time_sg
      t.integer :time_unit

      t.timestamps null: false
    end

    states = LineItem.state_machine.states.map(&:name)
    timelines = states.inject([]) { |timelines, state| timelines << StatesTimeline.new(state: state); timelines }
    StatesTimeline.import timelines
  end

  def down
    drop_table :states_timelines
  end
end
