class Manager::SettingsController < ApplicationController
  before_action :authenticate_manager!
  
  def matter_task_new
    @default_matter_tasks = current_manager.tasks
    @matter_task = current_manager.tasks
  end
  
  def default_matter_task_create
    if current_manager.tasks.create(default_task_params)
      @default_matter_tasks = current_manager.tasks
      respond_to do |format|
        format.js
      end
    else
    end
  end
  
  def default_matter_task_update
  end
  
  private
    
    def default_task_params
      params.require(:task).permit(:title, :memo)
    end
end
