class BasesController < ApplicationController
  
  def index
    @bases = Base.all
  end
  
  def edit
  end
  
  def update
  end
  
  def destroy
  end
  
  def new
  end
  
  def create
    @base = Base.find(params[base_params])
    if @base.save
      flash[:success] = ""
      redirect_to bases_show_url
    else
      render :new
    end
  end
  
  private
  
    def base_params
      params.require(:base).parmit(:base_number, :base_name, :attendance_type)
    end
end
