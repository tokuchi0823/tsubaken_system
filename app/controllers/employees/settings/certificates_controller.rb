class Employees::Settings::CertificatesController < ApplicationController
  before_action :authenticate_admin_or_manager!
  before_action :set_certificate, only: [:edit, :update, :destroy]

  def new
    @certificate = Certificate.new
  end

  def create
    @certificate = Certificate.new(certificate_params.merge(default: true))
    if @certificate.save
      flash[:success] = "診断書を作成しました。"
      redirect_to employees_settings_certificates_url
    else
      respond_to do |format|
        format.js
      end
    end
  end

  def edit
  end

  def update
    if @certificate.update(certificate_params)
      flash[:success] = "診断書を更新しました。"
      redirect_to employees_settings_certificates_url
    else
      respond_to do |format|
        format.js
      end
    end
  end

  def index
    @certificates = Certificate.all.where(default: true)
  end

  def destroy
    @certificate.destroy ? flash[:success] = "診断書を削除しました。" : flash[:alert] = "診断書を削除できませんでした。"
    redirect_to employees_settings_certificates_url
  end

  private
    def certificate_params
      params.require(:certificate).permit(:title, :content, :default)
    end

    def set_certificate
      @certificate = Certificate.find(params[:id])
    end
end