class AddNextDayFlagToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :next_day_flag, :boolean
  end
end
