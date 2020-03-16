module AttendancesHelper
  require 'active_support/time'

  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      return '出社' if attendance.started_at.nil?
      return '退社' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    # どれにも当てはまらなかった場合はfalseを返します。
    return false
  end
  
  
  # 出勤時間と退勤時間を受け取り、在社時間を計算
  def working_times(start, finish, next_day_flag)
    if next_day_flag == "0" 
      format("%.2f", (((finish - start) / 60) /60.0))
    else
      format("%.2f", (((finisha - start) / 60) /60.0) + 24)
    end
  end 
  

  # 出社時間、退社時間のどちらか一方が空の時、falseを返す。  
  def attendances_invalid?
    attendances = true
    attendances_params.each do |id, item|
      if item[:started_at].blank? && item[:finished_at].blank?
        next
      elsif item[:started_at].blank? || item[:finished_at].blank?
        attendances = false
        break
      end
    end
    return attendances
  end
  
  # 時間外時間計算
  def overtime_calculation(attendance)
    if attendance.overtime_finished_at.present?
      if attendance.overtime_next_day_flag == "0" 
        l(attendance.overtime_finished_at.floor_to(15.minutes), format: :time).to_f + 
        l(attendance.overtime_finished_at.floor_to(15.minutes), format: :minute).to_f/60 - 
        l(@user.designated_work_end_time.floor_to(15.minutes), format: :time).to_f 
      else
        l(attendance.overtime_finished_at.floor_to(15.minutes), format: :time).to_f + 
        l(attendance.overtime_finished_at.floor_to(15.minutes), format: :minute).to_f/60 - 
        l(@user.designated_work_end_time.floor_to(15.minutes), format: :time).to_f + 24 
      end 
    end
  end
  
end