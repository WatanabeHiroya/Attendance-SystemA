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
  
  
  # 出勤時間と退勤時間を受け取り、在社時間を計算して返します。(viewから呼び出し)
  def working_times(start, finish)
    if params[:next_day_flag] == "1"
      format("%.2f", (((finish - start) / 60) /60.0) + 24)
    else
      format("%.2f", (((finish - start) / 60) /60.0))
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
end