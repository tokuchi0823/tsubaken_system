class Employees::AttendancesController < ApplicationController
  before_action :authenticate_admin_or_manager!
  before_action :set_one_month, only: :individual
  before_action :set_latest_30_year, only: :individual
  before_action :set_employees, only: [:daily, :individual]
  before_action :set_new_attendance, only: [:daily, :individual, :create]

  # 日別勤怠表示ページ
  def daily
    # 対象日を定義
    params[:day] && params[:day].present? ? @day = params[:day].to_date : @day = Date.current
    # 勤怠モデルと、マネージャー・スタッフ・外部スタッフ(所属の外注先を含めて)を事前に読み込む
    attendances = Attendance.where(worked_on: @day).where.not(started_at: nil).includes(:manager).includes(:staff).includes(external_staff: :supplier)
    @manager_attendances = attendances.where.not(manager_id: nil)
    @staff_attendances = attendances.where.not(staff_id: nil)
    @external_staff_attendances = attendances.where.not(external_staff_id: nil)
  end

  # 従業員別の月毎の勤怠表示ページ
  def individual
    if params[:year] && params[:year].present? && params[:month] && params[:month].present?
      @first_day = "#{params[:year]}-#{params[:month]}-01".to_date
      @last_day = @first_day.end_of_month
    end
    if params[:type] && params[:type] == "1" && params[:manager_id] && params[:manager_id].present?
      manager_id = params[:manager_id]
      @resource = Manager.find(manager_id)
    elsif params[:type] && params[:type] == "2" && params[:staff_id] && params[:staff_id].present?
      staff_id = params[:staff_id]
      @resource = Staff.find(staff_id)
    elsif params[:type] && params[:type] == "3" && params[:external_staff_id] && params[:external_staff_id].present?
      external_staff_id = params[:external_staff_id]
      @resource = ExternalStaff.find(external_staff_id)
    end
    @attendances = @resource.attendances.where(worked_on: @first_day..@last_day).where.not(started_at: nil).order(:worked_on) if @resource
  end

  def create
    @attendance = Attendance.new(employee_attendance_params)
    if @attendance.save
      flash[:success] = "勤怠を作成しました"
      redirect_to individual_employees_attendances_url
    else
      flash[:success] = @attendance.errors.full_messages
      redirect_to individual_employees_attendances_url
    end
  end

  def update
    @Attendance = Attendance.find(params[:id])
  end

  private
    # 直近30年をhashに(フォーム用)
    def set_latest_30_year
      @years_hash = Hash.new
      latest_year = @first_day.year
      [*latest_year - 30..latest_year].each { |year| @years_hash.store("#{year}年", year) }
      @years_hash = @years_hash.sort.reverse.to_h
    end

    def set_employees
      @managers = Manager.all
      @staffs = Staff.all
      @external_staffs = ExternalStaff.all
    end

    def set_new_attendance
      @new_attendance = Attendance.new
    end

    def employee_attendance_params
      params.require(:attendance).permit(:employee_type, :manager_id, :staff_id, :external_staff_id, :worked_on, :started_at, :finished_at)
    end

    def create_monthly_attendance_by_date(resource, date)
    end
end
