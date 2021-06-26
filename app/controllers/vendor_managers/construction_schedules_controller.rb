class VendorManagers::ConstructionSchedulesController < ApplicationController
  before_action :authenticate_vendor_manager!
  before_action :set_construction_schedule, except: :index

  def index
    @calendar_type = "vendors_schedule"
    if params[:start_date].present?
      @object_day = params[:start_date].to_date
    else
      @object_day = Date.current
    end
    @calendar_span = Span.new
    @calendar_span.simple_calendar(@object_day)
    construction_schedules_for_calendar(@calendar_span.first_day, @calendar_span.last_day)
  end

  def show
    date = params[:day].to_date
    @construction_report = @construction_schedule.construction_reports.find_by(work_date: date)
  end

  def edit
    @vendor = current_vendor_manager.vendor
    @vendor_staff_codes_ids = @vendor.vendor_member_ids_for_matter_select(@construction_schedule.matter)
  end

  # 担当者のみ変更可
  def update
    attr_set_for_update
    if @construction_schedule.update(update_params)
      @responce = "success"
      @reciever_notification_count = @construction_schedule.member_code.recieve_notifications.count
      @construction_schedules = @construction_schedule.matter.construction_schedules.includes(:materials).order_start_date
    end
  end

  def picture
    @construction_schedule_pictures = @construction_schedule.images
  end

  private

    def set_construction_schedule
      @construction_schedule = ConstructionSchedule.find(params[:id])
    end

    def update_params
      params.require(:construction_schedule).permit(:member_code_id)
    end

    def attr_set_for_update
      @construction_schedule.sender = login_user.member_code.id
      @construction_schedule.sender_auth = login_user.auth
      if params[:construction_schedule][:member_code_id].to_i != @construction_schedule.member_code_id
        @construction_schedule.before_member_code = @construction_schedule.member_code_id
      end
    end
end