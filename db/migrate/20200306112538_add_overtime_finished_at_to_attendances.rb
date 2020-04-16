class AddOvertimeFinishedAtToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_finished_at, :datetime
    add_column :attendances, :overtime_content, :string
    add_column :attendances, :overtime_instruction, :string
    add_column :attendances, :overtime_next_day_flag, :string
    add_column :attendances, :overtime_status, :string
    add_column :attendances, :overtime_change_check_box, :string
  end
end
