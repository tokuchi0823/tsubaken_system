class Employees::CoversController < Employees::EstimateMatters::EstimateMattersController

  def create
    @cover = current_estimate_matter.build_cover(covers_params)
    if @cover.save
      @responce = "success"
    else
      @responce = "failure"
    end
  end
  
  def edit
    @cover = Cover.find(params[:id])
    @image = @cover.image
    @publishers = Publisher.all
    @covers = Cover.where(default: true)
  end
  
  def update
    @cover = Cover.find(params[:id])
    if @cover.update(covers_params)
      @responce = "success"
    else
      @responce = "failure"
    end
  end
  
  def destroy
    @cover = Cover.find(params[:id])
    @cover.destroy
  end
  
  private
    def covers_params
      params.require(:cover).permit(:publisher_id, :title, :content, :image_id)
    end

end