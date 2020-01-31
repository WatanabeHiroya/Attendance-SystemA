require 'csv'

CSV.generate do |csv|
  column_names = %w(日付 出社 退社)
  csv << column_names
  @attendances.each do |attendance|
    column_values = [
      attendance.worked_on,
      if !attendance.started_at.nil
      attendance.started_at,strftime("%h:%m"),
      else
      attendance.started_at,
      end
      attendance.finished_at
    ]
    csv << column_values
  end
end