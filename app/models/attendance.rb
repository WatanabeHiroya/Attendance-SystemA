class Attendance < ApplicationRecord
  belongs_to :user
  
  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  # 出勤時間が存在しない場合、退勤時間は無効
  validate :finished_at_is_invalid_without_a_started_at
  # 出勤・退勤時間どちらも存在する時、出勤時間より早い退勤時間は無効
  validate :started_at_than_finished_at_fast_if_invalid
  validate :apply_overtime

  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end
  
  def started_at_than_finished_at_fast_if_invalid 
    if started_at.present? && finished_at.present? # もし出勤時間と退勤時間が存在するならば
      unless next_day_flag == "1" # 翌日チェックない時
      errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at # 出勤時間が退勤時間より遅い時
      end
    end
  end
  
  def apply_overtime
    if overtime_finished_at.present?
      errors.add('designated_work_end_time', "より早い終了予定時間は無効です。") if user.designated_work_end_time.strftime("%H:%M") > overtime_finished_at.strftime("%H:%M")
    end
  end
end
