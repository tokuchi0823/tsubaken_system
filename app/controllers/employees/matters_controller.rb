class Employees::MattersController < Employees::EmployeesController
  before_action :set_matter, except: [:new, :create, :index]
  # アクセス制限
  before_action ->{can_access_only_of_member(@matter)}, except: :index

  before_action :set_reports_of_matter, only: :show
  before_action :set_employees, only: [:new, :edit, :change_member]
  before_action ->{set_menbers_code_for(@matter)}, only: :show
  before_action ->{can_access_only_of_member(@matter)}, except: :index
  before_action :all_staff_and_external_staff_code, only: [:edit, :change_member]

  # 見積案件から案件を作成ページ
  def new
    @estimate_matter = EstimateMatter.find(params[:estimate_matter_id])
    @matter = Matter.new
    set_estimates_with_plan_names_and_label_colors
  end

  # 見積案件から案件を作成
  def create
    estimate_matter = EstimateMatter.find(params[:estimate_matter_id])
    @matter = estimate_matter.build_matter(estimate_matter.attributes.except("supplier_id").merge(estimate_id: params[:matter][:estimate_id].to_i,
                                                                                                  scheduled_started_on: params[:matter][:scheduled_started_on],
                                                                                                  scheduled_finished_on: params[:matter][:scheduled_finished_on]))
    @matter.save ? @responce = "success" : @responce = "failure"
  end

  def index
    @matters = Matter.all
    unless current_admin || current_manager
      @matters = Matter.joins(:member_codes).where(member_codes: { id: login_user.member_code.id })
    end
    # 進行状況での絞り込みがあった場合
    if params[:status] && params[:status] == "not_started"
      @matters = @matters.where(status: "not_started")
    elsif params[:status] && params[:status] == "progress"
      @matters = @matters.where(status: "progress")
    elsif params[:status] && params[:status] == "completed"
      @matters = @matters.where(status: "completed")
    end
  end

  def show
    @message = true if params[:type] == "success"
    set_matter_detail_valiable
    set_classified_tasks(@matter)
    set_estimates_with_plan_names_and_label_colors
    set_invoice_valiable
    @images = @matter.images.where(report_list: true).select{ |image| image.image.attached? }
    @report_cover = @matter.report_cover
    set_images_of_report_cover if @report_cover.present?
    gon.matter_id = @matter.id
    @construction_schedules = @matter.construction_schedules.includes(:materials, :vendor).order_start_date
    @supplier = @estimate_matter.supplier
    @msg_to_switch_type = @estimate_matter.supplier_id ? "自社案件に切替" : "他社案件に切替"
  end

  def edit
    # @estimates = @matter.estimate_matter.estimates.with_plan_names_and_label_colors
    # @external_staff_codes_ids = @matter.member_codes.joins(:external_staff).ids
    case params[:edit_type]
    when "basic"
      @edit_type = "basic"
    when "staff"
      @edit_type = "staff"
      @staff_codes_ids = @matter.member_codes.joins(:staff).ids
    when "vendor"
      @edit_type = "vendor"
      @vendors = Vendor.all
    when "vendor_staff"
      @edit_type = "vendor_staff"
      @vendor = Vendor.find(params[:vendor_id])
      @vendor_staff_codes_ids = @vendor.external_staffs.joins(:member_code)
                                                           .select('external_staffs.*, member_codes.id AS member_code_id')
    when "alert"
      @edit_type = "vendor_alert"
      difference_ids = params[:difference].map{|id| id.to_i }
      @alert_vendors = Vendor.where(id: difference_ids)
    end
  end

  def update
    if @matter.update(matter_params)
      if params[:matter][:vendor_ids].present?
        delete_vendor_staff_for_delete_vendor
      end
      flash[:success] = "案件情報を更新しました"
      redirect_to employees_matter_url(@matter)
    end
  end

  def destroy
    @matter.destroy ? flash[:success] = "案件を削除しました" : flash[:alert] = "案件を削除できませんでした"
    redirect_to employees_matters_url
  end

  def change_estimate
    if @matter.change_invoice(params[:matter][:estimate_id])
      @responce = "success"
      @invoice = @matter.invoice
      set_invoice_details
    else
      @responce = "failure"
    end
  end

  def calendar
    if params[:start_date].present?
      @object_day = params[:start_date].to_date
    else
      @object_day = Date.current
    end
    @calendar_span = Span.new
    @calendar_span.simple_calendar(@object_day)
    construction_schedules_for_matter_calender(@matter, @calendar_span.first_day, @calendar_span.last_day)
    @calendar_type = "construction_schedule_for_matter"
  end

  private
    def matter_params
      params.require(:matter).permit(:title, :content, :postal_code, :prefecture_code, :address_city, :address_street, :scheduled_started_on,
                                     :scheduled_finished_on, :status, :estimate_id, :started_on, :finished_on, :maintenanced_on,
                                     { vendor_ids: [] })
    end

    def set_matter_detail_valiable
      @address = "#{ @matter.prefecture_code }#{ @matter.address_city }#{ @matter.address_street }"
      @vendors = @matter.vendors
      @client = @matter.client
      @estimate_matter = @matter.estimate_matter
    end

    def set_invoice_valiable
      @invoice = @matter.invoice
      set_plan_name_of_invoice
      set_color_code_of_invoice
      set_invoice_details
    end

    def delete_vendor_staff_for_delete_vendor
      vendors_ids = @matter.vendors.ids
      delete_vendor_staffs = @matter.member_codes.joins(:external_staff)
                                                   .where.not(external_staffs: {vendor_id: vendors_ids})
      delete_matter_member_codes = @matter.matter_member_codes.where(member_code_id: delete_vendor_staffs)
      delete_matter_member_codes.each do |matter_member_code|
        matter_member_code.destroy
      end
    end
end
