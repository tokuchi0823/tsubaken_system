class Employees::ManagersController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_manager, only: [:show, :update, :destroy]

  def create
    @manager = Manager.new(manager_params.merge(password: "password", password_confirmation: "password"))
    if @manager.save
      flash[:success] = "マネージャーを作成しました"
      redirect_to employees_manager_url(@manager)
    else
      respond_to do |format|
        format.js
      end
    end
  end

  def index
    @manager = Manager.new
    @managers = Manager.all
  end

  def show
  end

  def update
    if @manager.update(manager_params)
      flash[:success] = "マネージャー情報を更新しました"
      redirect_to employees_manager_url(@manager)
    else
      respond_to do |format|
        format.js
      end
    end
  end

  def destroy
    @manager.destroy ? flash[:success] = "マネージャーを削除しました" : flash[:alert] = "マネージャーを削除できませんでした"
    redirect_to employees_managers_url
  end

  private
    def manager_params
      params.require(:manager).permit(:name, :login_id, :phone, :email, :birthed_on, :zipcode, :address, :joined_on, :resigned_on)
    end

    def set_manager
      @manager = Manager.find(params[:id])
    end
end
