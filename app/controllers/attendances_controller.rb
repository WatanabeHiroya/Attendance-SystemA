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
  
  def approve_attendances
    approve_attendances_params.each do |id, status|
      attendance = Attendance.find(id)
      attendance.update_attributes(status)
    end
    redirect_to user_url
  end
  
  def fix_log
    # 変更した勤怠情報のみを取得
  end

  private

    # 1ヶ月分の勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :first_start_time, :first_end_time, :second_start_time, :second_end_time, :next_day_flag, :instruction])[:attendances]
    end
    
    def approve_attendances_params
      params.require(:user).permit(attendances: :status)
    end
end