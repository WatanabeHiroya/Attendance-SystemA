class AddCheckToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :check, :string
  end
end
