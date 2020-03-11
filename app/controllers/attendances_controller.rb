class AttendancesController < ApplicationController
  include AttendancesHelper
  
  before_action :set_user, only: [:edit_one_month, :update_one_month, :fix_log]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month, :fix_log]
  before_action :set_one_month, only: [:edit_one_month, :fix_log]

  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"

  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end

  def edit_one_month
    @attendances.each do |attendance|
      attendance.update_attributes(first_start_time: attendance.started_at, first_end_time: attendance.finished_at)
    end
  end

  def update_one_month
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      if attendances_invalid? # 出社時間、退社時間のどちらか一方が空の時、falseを返す。
        attendances_params.each do |id, item|
          attendance = Attendance.find(id)
          attendance.update_attributes!(item)
          attendance.update_attributes!(second_start_time: attendance.started_at, second_end_time: attendance.finished_at)
          # 指示者を選択した勤怠情報のみ、statusを申請中に更新
          unless attendance.instruction == "" 
            attendance.update_attributes!(status: "申請中")
          end
        end
        flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
        redirect_to user_url(date: params[:date])
      else
        flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
        redirect_to attendances_edit_one_month_user_url(date: params[:date])
      end
    end        
    rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
      flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
      redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  # 勤怠変更申請のお知らせ
  def show_changed_request
    @change_attendances = Attendance.where(status: "申請中")
    @change_users = []    #ここで重複をさせない
    @change_attendances.each do |change_attendance|
      @change_users.push(User.find_by(id: change_attendance.user_id))
    end
    @change_users = @change_users.uniq #配列の重複をなくす
  end
  
  def approve_changed_request
    approve_attendances_params.each do |id, status|
      attendance = Attendance.find(id)
      attendance.update_attributes(status)
    end
    redirect_to user_url
  end
  
  def fix_log
    # 該当月に変更した勤怠情報のみを取得
    @attendances = @attendances.where(status: "承認")
  end
  
  # 残業申請モーダル
  def show_apply_overtime
    @attendance = Attendance.find(params[:id])
  end
  
  # 残業申請
  def apply_overtime
    show_apply_overtime
    @attendance.update_attributes(overtime_params)
    flash[:success] = "残業申請を送信しました。"
    redirect_to user_url(@attendance.user_id)
  end
  
  # 残業申請のお知らせ
  def show_overtime_request
    @attendances = Attendance.where(overtime_status: "申請中")
    
    @users = []
    @attendances.each do |attendance|
      @users.push(User.find_by(id: attendance.user_id))
    end
    @users = @users.uniq
  end
  
  # 残業承認
  def approve_overtime_request
  end
  

  private

    # 1ヶ月分の勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :first_start_time, :first_end_time, :second_start_time, :second_end_time, :next_day_flag, :instruction])[:attendances]
    end
    
    def approve_attendances_params
    # require(:attendance)は必要ない？
      params.permit(attendances: [:id, :status])[:attendances]
    end
    
    #残業申請情報
    def overtime_params
      params.require(:attendance).permit(:id, :overtime_finished_at, :overtime_next_day_flag, :overtime_content, :overtime_instruction)
    end
end