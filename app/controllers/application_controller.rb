class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_manager
  helper_method :current_matter
  helper_method :current_admin
  
  
  # ---------------------------------------------------------
        # FORMAT関係
  # ---------------------------------------------------------
  
  # login画面等のデザインformat指定
  def non_approval_layout
    @type = "log_in"
  end
  
  # ---------------------------------------------------------
        # 日付取得関係　matter/ganttchart attendance
  # ---------------------------------------------------------
  
  def set_one_month
    @first_day = params[:date].nil? ? Date.current.beginning_of_month : params[:date].to_date.beginning_of_month
    @last_day = @first_day.end_of_month
    @one_month = [*@first_day..@last_day]
  end
  
  
  # ---------------------------------------------------------
        # ADMIN関係
  # ---------------------------------------------------------

  # 管理者権限者が一人に以上の場合、管理者画面お表示で知らせる。
  def admin_limit_1
    if Admin.count > 1
      @condition = "danger"
    else
      @condition = "dark"
    end
  end

  # Attendance用、マネージャー・スタッフ・外部スタッフ、それぞれの一月分勤怠レコードを生成
  def create_monthly_attendances(resource)
    @attendances = resource.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    unless @attendances.length == @one_month.length
      ActiveRecord::Base.transaction do
        @one_month.each { |day| resource.attendances.create!(worked_on: day) }
      end
      @attendances = resource.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    end
  rescue ActiveRecord::RecordInvalid 
    flash[:danger] = "勤怠情報の取得に失敗しました"
    redirect_to root_url
  end
  
  # アクセス制限
  def only_admin!
    unless Admin.first.id == current_admin.id 
      flash[:alert] = "アクセス権限がありません"
      redirect_to root_path
    end
  end

  # ログインmanager以外のページ非表示
  # def not_current_admin_return_login!
  #   unless params[:manager_id] == current_admin.public_uid || params[:manager_public_uid] == current_admin.public_uid || params[:id] == current_admin.public_uid
  #     flash[:alert] = "アクセス権限がありません"
  #     redirect_to root_path
  #   end
  # end
  
  # ---------------------------------------------------------
        # STAFF関係
  # ---------------------------------------------------------
  
  # ログインstaff以外のページ非表示
  def not_current_staff_return_login!
    unless params[:id].to_i == current_staff.id || params[:staff_id].to_i == current_staff.id
      flash[:alert] = "アクセス権限がありません"
      redirect_to root_path
    end
  end
  
  # ---------------------------------------------------------
        # USER関係
  # ---------------------------------------------------------
  
  # ログインstaff以外のページ非表示
  def not_current_user_return_login!
    unless params[:id].to_i == current_user.id || params[:user_id].to_i == current_user.id
      flash[:alert] = "アクセス権限がありません"
      redirect_to root_path
    end
  end
  
  
  # --------------------------------------------------------
        # MATTER関係
  # --------------------------------------------------------
  
  def current_matter
    Matter.find_by(id: params[:matter_id]) || Matter.find_by(id: params[:id])
  end
  
  # def matter_index_authenticate!
  #   if current_admin && current_admin.public_uid == params[:manager_public_uid]
  #     @matters = current_admin.matters
  #   elsif current_submanager && current_admin.public_uid == params[:manager_public_uid]
  #     @matters = current_admin.matters
  #   elsif current_staff
  #     @matters = current_staff.matters
  #   else
  #     flash[:alert] = "アクセス権限がありません"
  #     redirect_to matter_matters_url(current_admin)
  #   end
  # end
  
  
  # --------------------------------------------------------
        # TASK関係
  # --------------------------------------------------------
  
  def default_tasks
    Task.where.not(default_title: nil).are_default_tasks
  end
  
  # 使用回数を保存
  def count_default_task
    default_tasks.each do |task|
      priority_count = Task.where(default_title: task.default_title).where.not(status: nil).count
      task.update(priority_count: priority_count)
    end
  end
  
  # 並び順更新_____________________________________________________
  def reload_row_order(tasks)
    tasks.each_with_index do |task, i|
      task.update(row_order: i * 100)
    end
  end
      
  def matter_task_type
    if admin_signed_in? || manager_signed_in?
      count_default_task
      @default_tasks = default_tasks.are_default_tasks.are_matter_tasks_for_commonly_used
    end
    @matter_tasks = current_matter.tasks.are_matter_tasks
    # row_orderリセット
    reload_row_order(@matter_tasks)
    @matter_progress_tasks = current_matter.tasks.are_progress_tasks
    # row_orderリセット
    reload_row_order(@matter_progress_tasks)
    @matter_complete_tasks = current_matter.tasks.are_finished_tasks
    # row_orderリセット
    reload_row_order(@matter_complete_tasks)
  end
    
  private
  
  # --------------------------------------------------------
        # DEVISE関係
  # --------------------------------------------------------
  
  # ログイン後のリダイレクト先
  def after_sign_in_path_for(resource_or_scope)
    if resource_or_scope.is_a?(Admin)
      top_admin_path(current_admin)
    elsif resource_or_scope.is_a?(Manager)
      top_manager_path(current_manager)
    elsif resource_or_scope.is_a?(Staff)
      top_staff_path(current_staff)
    elsif resource_or_scope.is_a?(User)
      top_user_path(current_user)
    else
      root_path
    end
  end

  # AdminとManager以外はアクセス制限
  def authenticate_admin_or_manager!
    redirect_to root_url unless current_admin || current_manager
  end

  # 従業員以外はアクセス制限
  def authenticate_employee!
    redirect_to root_url unless current_admin || current_manager || current_staff
  end
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,keys:[:email])
  end
end
