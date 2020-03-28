require 'csv'
class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :update_user_info, :show_apply_affiliation, :show_changed_request, :show_overtime_request]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :update_user_info]
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info, :index, :update_user_info]
  before_action :set_one_month, only: :show
  before_action :admin_or_correct_user, only: [:show, :edit, :update]
  before_action :show_apply_affiliation, only: :show
  before_action :show_changed_request, only: :show
  before_action :show_overtime_request, only: :show

  def index
    @users = User.paginate(page: params[:page], per_page: 10)
  end
  
  def show
    respond_to do |format|
      format.html
      format.csv do |csv|
        send_attendances_csv(@attendances)
      end
    end
    @worked_sum = @attendances.where.not(started_at: nil).count
    # 所属長承認申請用（月初日）
    @attendance = @attendances[0]
  end
  
  def send_attendances_csv(attendances)
    csv_data = CSV.generate do |csv|
      header = %w(日付 出社 退社)
      csv << header
      
      attendances.each do |attendance|
        values = [
          attendance.worked_on,
          if attendance.started_at.present?
           attendance.started_at.strftime("%R")
          end,
          if attendance.finished_at.present?
           attendance.finished_at.strftime("%R") 
          end
          ]
        csv << values
      end
    end
    send_data(csv_data, filename: "attendances.csv")
  end

  def new
    @user = User.new
  end

  def create
    if params[:users_file]
      registered_count = import_users
      flash[:success] = "#{registered_count}件登録しました。"
      redirect_to users_url
    else
      @user = User.new(user_params)
      if @user.save
        log_in @user
        flash[:success] = '新規作成に成功しました。'
        redirect_to @user
      else
        render :new
      end
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to root_url
    else
      render :edit      
    end
  end
  
  def update_user_info
    if @user.update_attributes(user_info_params)
      flash[:success] = "ユーザー情報を編集しました。"
      redirect_to users_url
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end

  def edit_basic_info
  end

  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
  
  def working_employee_list
    @users = User.all.includes(:attendances)
  end
  
  # 所属長申請のお知らせ
  def show_apply_affiliation
    if @user.name == "上長1"
      @affiliation_attendances = Attendance.where(affiliation_status: "申請中").where(affiliation_instruction: "上長1")
    elsif @user.name == "上長2"
      @affiliation_attendances = Attendance.where(affiliation_status: "申請中").where(affiliation_instruction: "上長2")
    end
    @affiliation_users = []
    @affiliation_attendances.each do |attendance|
      @affiliation_users.push(User.find_by(id: attendance.user_id))
    end
    @affiliation_users = @affiliation_users.uniq
  end
  
  # 勤怠変更申請のお知らせ
  def show_changed_request
    if @user.name == "上長1"
      @change_attendances = Attendance.where(status: "申請中").where(instruction: "上長1")
    elsif @user.name == "上長2"
      @change_attendances = Attendance.where(status: "申請中").where(instruction: "上長2")
    end
    @change_users = []    
    @change_attendances.each do |change_attendance|
      @change_users.push(User.find_by(id: change_attendance.user_id))
    end
    @change_users = @change_users.uniq #配列の重複をなくす
  end
  
  # 残業申請のお知らせ
  def show_overtime_request
    if @user.name == "上長1"
      @overtime_attendances = Attendance.where(overtime_status: "申請中").where(overtime_instruction: "上長1")
    elsif @user.name == "上長2"
      @overtime_attendances = Attendance.where(overtime_status: "申請中").where(overtime_instruction: "上長2")
    end
    @overtime_users = []
    @overtime_attendances.each do |attendance|
      @overtime_users.push(User.find_by(id: attendance.user_id))
    end
    @overtime_users = @overtime_users.uniq
  end


  private

    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :password, :password_confirmation)
    end

    def basic_info_params
      params.require(:user).permit(:basic_work_time, :work_time)
    end
    
    def user_info_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, :password, :password_confirmation, :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end

    def import_users
    # ActiveRecord::Base.transaction do # トランザクション
        # 登録処理前のレコード数
        current_user_count = ::User.count
        users = []
        # windowsで作られたファイルに対応するので、encoding: "SJIS"を付けている
        CSV.foreach(params[:users_file].path, headers: true, encoding: "SJIS") do |row|
          users << ::User.new({ name: row["name"], email: row["email"], affiliation: row["affiliation"], employee_number: row["employee_number"], uid: row["uid"], basic_work_time: row["basic_work_time"], designated_work_start_time: row["designated_work_start_time"], designated_work_end_time: row["designated_work_end_time"], superior: row["superior"], admin: row["admin"], password: row["password"]})
        end
        # importメソッドでバルクインサートできる
        ::User.import(users)
        # 何レコード登録できたかを返す
        ::User.count - current_user_count
    #  end
    # rescue ActiveRecord::RecordNotUnique # トランザクションにエラー
    #  flash[:danger] = "無効な入力データがあった為、キャンセルしました。"
    #  redirect_to users_url
    end

end