class AddAffiliationsToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :affiliation_status, :string
    add_column :attendances, :affiliation_instruction, :string
  end
end
