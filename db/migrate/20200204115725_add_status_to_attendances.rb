class AddStatusToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :status, :string
    add_column :attendances, :change_check_box, :string
  end
end
