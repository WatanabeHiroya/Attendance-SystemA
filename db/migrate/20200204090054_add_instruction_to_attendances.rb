class AddInstructionToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :instruction, :string
  end
end
