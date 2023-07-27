class BasesController < ApplicationController
  before_action :set_base, only: [:edit, :update, :destroy]
  def new
    @base = Base.new
  end

  def index
    @bases = Base.all
  end

  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = "拠点登録完了しました。"
      redirect_to bases_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @base.update(base_params)
      flash[:success] = "指定した拠点情報を修正致しました。"
      redirect_to bases_path
    else
      render :edit
    end
  end

  def destroy
    @base.destroy
    flash[:success] = "削除されました。"
    redirect_to bases_path
  end

  private
  def set_base
    @base = Base.find(params[:id])
  end

  def base_params
    params.require(:base).permit(:name, :base_number, :base_type)
  end
end
