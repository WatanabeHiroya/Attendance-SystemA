class BasesController < ApplicationController
  before_action :admin_user, only: [:index, :edit, :update, :destroy, :new, :create]
  
  def index
    @bases = Base.all
  end
  
  def edit
    @base = Base.find(params[:id])
  end
  
  def update
    @base = Base.find(params[:id])
    if @base.update_attributes(base_params)
      flash[:success] = "拠点情報を修正しました。"
      redirect_to bases_url
    else
      render :edit
    end
  end
  
  def destroy
    @base = Base.find(params[:id])
    if @base.destroy
      flash[:success] = "拠点情報を削除しました。"
      redirect_to bases_url
    end
  end
  
  def new
    @base = Base.new
  end
  
  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = "新規作成に成功しました。"
      redirect_to bases_url
    else
      render :new
    end
  end
  
  private
  
    def base_params
      params.require(:base).permit(:base_number, :base_name, :attendance_type)
    end
end
