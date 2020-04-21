class AttendancesController < ApplicationController
  include AttendancesHelper
  
  before_action :set_user, only: [:edit_one_month, :update_one_month, :fix_log, :apply_affiliation]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month, :fix_log]
  before_action :set_one_month, only: [:edit_one_month, :fix_log, :apply_affiliation]
  before_action :not_admin_user, only: :edit_one_month

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
          unless item[:instruction] == ""
            attendance.update_attributes!(item)
            attendance.update_attributes!(second_start_time: attendance.started_at, second_end_time: attendance.finished_at, status: "申請中")
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
  
  # 勤怠変更申請承認
  def approve_changed_request
    approve_attendances_params.each do |id, item|
      attendance = Attendance.find(id)
      attendance.update_attributes(item) if item[:check] == "1"
    end
    flash[:info] = "勤怠変更申請を更新しました。"
    redirect_to user_url
  end
  
  def fix_log
    # 該当月に変更した勤怠情報のみを取得
    @attendances = @attendances.where(status: "承認")
  end
  
  # 残業申請モーダル
  def show_apply_overtime
    @attendance = Attendance.find(params[:id])
    @user = User.find(@attendance.user_id)
  end
  
  # 残業申請
  def apply_overtime
    show_apply_overtime
    if @attendance.finished_at.present?
      if @attendance.update_attributes(overtime_params)
        unless @attendance.overtime_instruction == "" 
          @attendance.update_attributes(overtime_status: "申請中")
          flash[:success] = "残業申請を送信しました。"
          redirect_to user_url(@attendance.user_id)
          return
        end
      else         
        flash[:danger] = "指定勤務終了時間より早い終了予定時間は無効です。"
        redirect_to user_url(@attendance.user_id)
        return
      end
    end
    flash[:danger] = "退社時間が未入力です。"
    redirect_to user_url(@attendance.user_id)
  end
  
  # 残業承認
  def approve_overtime_request
    approve_overtime_params.each do |id, item|
      attendance = Attendance.find(id)
      attendance.update_attributes(item) if item[:check] == "1"
    end
    flash[:info] = "残業申請を更新しました。"
    redirect_to user_url
  end
  
  # 所属長承認申請
  def apply_affiliation
    # 月初日の勤怠情報を取得
    @attendance = @attendances[0]
    @attendance.update_attributes(affiliation_params)
    flash[:info] = "所属長承認申請を送信しました"
    redirect_to user_url(@attendance.user_id)
  end
  
  # 所属長承認申請承認
  def approve_affiliation
    approve_affiliation_params.each do |id, item|
      attendance = Attendance.find(id)
      attendance.update_attributes(item) if item[:check] == "1"
    end
    flash[:info] = "所属長承認申請を更新しました。"
    redirect_to user_url
  end
  
  

  private

    # 1ヶ月分の勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :first_start_time, :first_end_time, :second_start_time, :second_end_time, :next_day_flag, :instruction])[:attendances]
    end
    
    # 勤怠変更申請承認
    def approve_attendances_params
    # require(:attendance)は必要ない？
      params.permit(attendances: [:status, :check])[:attendances]
    end
    
    # 残業申請情報
    def overtime_params
      params.require(:attendance).permit(:overtime_finished_at, :overtime_next_day_flag, :overtime_content, :overtime_instruction)
    end
    
    # 残業申請承認
    def approve_overtime_params
      params.permit(attendances: [:overtime_status, :check])[:attendances]
    end
    
    # 所属長申請
    def affiliation_params
      params.permit(attendance: [:affiliation_status, :affiliation_instruction])[:attendance]
    end
    
    # 所属長承認
    def approve_affiliation_params
      params.permit(attendances: [:affiliation_status, :check])[:attendances]
    end
end