class Employees::Matters::ConstructionSchedulesController < Employees::EmployeesController
  before_action :set_matter_by_matter_id
  before_action ->{can_access_only_of_member(@matter)}
  before_action :set_construction_schedule, except: [:new, :create, :set_estimate_category]

  def new
    @construction_schedule = @matter.construction_schedules.new
    @vendors = @matter.vendors
  end

  def create
    @construction_schedule = @matter.construction_schedules.new(construction_schedule_params)
    @construction_schedule.sender = login_user.member_code.id
    if @construction_schedule.save(context: :normal_commit)
      @responce = "success"
      @construction_schedule.set_start_date_and_end_date
      @reciever_notification_count = @construction_schedule.member_code.recieve_notifications.count
      @construction_schedules = @matter.construction_schedules.includes(:materials).order_start_date
    else
      @responce = "failure"
    end
  end

  def show
    date = params[:day].to_date
    @construction_report = @construction_schedule.construction_reports.find_by(work_date: date)
  end

  def edit
    @vendors = @matter.vendors
  end

  def update
    attr_set_for_update
    @construction_schedule.attributes = construction_schedule_params
    if @construction_schedule.save(context: :normal_commit)
      @responce = "success"
      @construction_schedule.set_start_date_and_end_date
      @reciever_notification_count = @construction_schedule.member_code.recieve_notifications.count
      @construction_schedules = @matter.construction_schedules.includes(:materials).order_start_date
    else
      @responce = "failure"
    end
  end

  def destroy
    if @construction_schedule.member_code_id.present?
      @construction_schedule.sender = login_user.member_code.id
    end
    if @construction_schedule.destroy
      @responce = "success"
      @construction_schedules = @matter.construction_schedules.order_start_date
      if @construction_schedule.member_code_id.present?
        @reciever_notification_count = @construction_schedule.member_code.recieve_notifications.count
        @notification = true
      end
    else
      @responce = "failure"
    end
  end

  def picture
    @construction_schedule_pictures = @construction_schedule.images
  end

  def edit_for_picture
    estimate_matter = @matter.estimate_matter
    @pictures = estimate_matter.images
    if @pictures.present?
      @type = "success"
    else
      @type = "failure"
    end
  end

  def update_for_picture
    @construction_schedule.construction_schedule_images.destroy_all
    params[:construction_schedule][:image_ids].each do |params_image|
      @construction_schedule.construction_schedule_images.create(image_id: params_image[:image_id])
    end
    @construction_schedules = @matter.construction_schedules.includes(:materials).order_start_date
  end

  def set_estimate_category
    estimate = @matter.estimate
    @estimate_info = estimate.estimate_details.left_joins(:material, :construction)
                                              .select('estimate_details.*, materials.id AS material_id, constructions.name AS construction_name')
                                              .group_by{|estimate_detail| estimate_detail.category_id}
    @estimate_info.each do |category_id, info|
      category = Category.find(category_id)
      if category.classification == "common" || category.classification == "material"
        construction_schedule = @matter.construction_schedules.create(title: "#{category.name}塗装")
        info.each do |info|
          # 素材の場合
          if info.material_id.present?
            construction_schedule.construction_schedule_materials.create(material_id: info.material_id)
          end
        end
      else
        # 工事の場合
        info.each do |info|
          @matter.construction_schedules.create(title: info.construction_name)
        end
      end
    end
    @construction_schedules = @matter.construction_schedules.includes(:materials).order_start_date
  end

  def edit_for_materials
    @all_Materials = Material.all
  end

  def update_for_materials
    if @construction_schedule.update(construction_schedule_material_params)
      @responce = "success"
      @construction_schedules = @matter.construction_schedules.order_start_date
    else
      @responce = "failure"
    end
  end

  private
    def construction_schedule_params
      params.require(:construction_schedule).permit(:title, :content, :scheduled_started_on, :scheduled_finished_on, :vendor_id,
                                                    :disclose, :started_on, :finished_on)
    end

    def construction_schedule_material_params
      params.require(:construction_schedule).permit(material_ids: [])
    end

    def set_construction_schedule
      @construction_schedule = ConstructionSchedule.find(params[:id])
    end

    def attr_set_for_update
      @construction_schedule.sender = login_user.member_code.id
      @construction_schedule.before_title = @construction_schedule.title
      # 担当者変更
      if params[:construction_schedule][:member_code_id].to_i != @construction_schedule.member_code_id
        @construction_schedule.before_member_code = @construction_schedule.member_code_id
        @update_type = "member_change"
      end
      # 着工予定日変更
      if params[:construction_schedule][:scheduled_started_on] != @construction_schedule.scheduled_started_on
        @construction_schedule.before_scheduled_started_on = @construction_schedule.scheduled_started_on
      end
      # 完了予定日変更
      if params[:construction_schedule][:scheduled_finished_on] != @construction_schedule.scheduled_finished_on
        @construction_schedule.before_scheduled_finisied_on = @construction_schedule.scheduled_finished_on
      end
      # 内容変更
      if params[:construction_schedule][:content] != @construction_schedule.content
        @construction_schedule.before_content = @construction_schedule.content
      end
      # 上司に通知
      if @update_type.present?
        before_member = MemberCode.find(@construction_schedule.member_code_id)
        if before_member.parent.auth == "external_staff"
          @construction_schedule.reciever_auth = "external_staff"
          @construction_schedule.reciever_boss =  before_member.parent.boss.member_code.id
        end
      else
        member = MemberCode.find(@construction_schedule.member_code_id)
        if member.parent.auth == "external_staff"
          @construction_schedule.reciever_auth = "external_staff"
          @construction_schedule.reciever_boss =  before_member.parent.boss.member_code.id
        end
      end
    end

end
