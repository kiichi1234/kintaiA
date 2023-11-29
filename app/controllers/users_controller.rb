class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :overtime_application, :overtime_confirmation]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:show, :edit, :update, :overtime_application]
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info]
  before_action :set_one_month, only: :show
  before_action :approve_onemonth, only: :show
  before_action :attendances_change, only: :show
  before_action :overtime_confirmation, only: :show

 def index
  if params[:search].blank?
    @users = User.paginate(page: params[:page])
  else
    @users = User.where("name LIKE ?", "%#{params[:search]}%").paginate(page: params[:page])
  end
 end


 def show
  @worked_sum = @attendances.where.not(started_at: nil).count
  @superiors = User.where(manager: true).where.not(id: current_user.id).pluck(:name, :id)
  @one_month_count = @approve_one_month_notifications.group_by { |n| n.manager_id }.transform_values(&:size)
  @attendances_count = @attendances_notifications.group_by { |n| n.manager_id }.transform_values(&:size)
  @overtime_count = @overtime_notifications.group_by { |n| n.manager_id }.transform_values(&:size)
 end

 def show_update
  @user = User.find(params[:user_id])
  @first_day = Date.parse(params[:first_day])
  attendance = Attendance.find_by(user_id: @user.id, worked_on: @first_day)
  
  if attendance
    # 既存の通知がないかチェック
    existing_notification = Notification.find_by(
      user_id: @user.id,
      manager_id: params[:manager_id],
      attendance_id: attendance.id,
      source: 'show_update'
    )

    # 既存の通知がある場合は二重申請を防止
    if existing_notification
      flash[:danger] = '既に申請されています。'
    else
      # 通知の作成と保存
      notification = Notification.new(
        user_id: @user.id,
        manager_id: params[:manager_id],
        attendance_id: attendance.id,
        requested_month: params[:first_day],
        source: 'show_update'
        # その他の必要なデータ
      )

      if notification.save
        flash[:success] = '申請しました'
      else
        flash[:danger] = '申請に失敗しました: ' + notification.errors.full_messages.join(', ')
      end
    end
  else
    flash[:danger] = '関連する勤怠データが見つかりませんでした。'
  end
  
  redirect_to user_url(date: params[:date])
end




  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end

  def import_csv
    # ファイルがアップロードされたことを確認する
    if params[:file].blank?
      flash[:warning] = 'ファイルを選択してください。'
    else
      successfully_imported, _ = User.import(params[:file])
      
      if successfully_imported == 0
        flash[:warning] = 'インポートが正常に出来ませんでした。再確認してください。'
      else
        flash[:success] = "#{successfully_imported} users were successfully imported."
      end
    end
    redirect_to users_path
  end
  
  def attendances_change
    @attendances_notifications = Notification.where(manager_id: current_user.id, source: 'update_one_month').includes(:attendance)
  end
  
  def approved_log
    @year = params[:year].present? ? params[:year].to_i : Date.today.year
    @month = params[:month].present? ? params[:month].to_i : Date.today.month
    start_date = Date.new(@year, @month, 1)
    end_date = start_date.end_of_month
  
    @approved_notifications = Notification.joins(:attendance)
      .where(user_id: current_user, status: '承認')
      .where("attendances.worked_on BETWEEN ? AND ?", start_date, end_date)
  end


  def approve_onemonth
    @approve_one_month_notifications = Notification.joins(:user).where(source: 'show_update', manager_id: current_user.id).select('notifications.*, users.name as user_name')

  end
  
  def overtime_application
    @attendance = @user.attendances.find_by(worked_on: params[:date])
    @superiors = User.where(manager: true).where.not(id: current_user.id).pluck(:name, :id)
  end

  def update_overtime_application
    @user = User.find(params[:id])
    @attendance = Attendance.find_by(user_id: @user.id, worked_on: params[:date])
  
    if @attendance
      # 既存の通知がないかチェック
      existing_notification = Notification.find_by(
        user_id: @user.id,
        manager_id: params[:user][:manager_id],
        attendance_id: @attendance.id,
        source: 'overtime'
      )
  
      # 既存の通知がある場合は二重申請を防止
      if existing_notification
        flash[:danger] = '既に残業申請がされています。'
      else
        # 通知の作成と保存
        notification = Notification.new(
          user_id: @user.id,
          manager_id: params[:user][:manager_id],
          attendance_id: @attendance.id,
          content: params[:user][:note],
          scheduled_end: params[:user][:scheduled_end],
          next_day: params[:user][:next_day],
          source: 'overtime'
        )
      
        if notification.save
          flash[:success] = '残業申請が完了しました。'
        else
          flash[:danger] = '残業申請に失敗しました: ' + notification.errors.full_messages.join(', ')
        end
      end
    else
      flash[:danger] = '勤怠データが見つかりません。'
    end
  
    redirect_to user_path(@user)
  end
  
  
  def overtime_confirmation
    @overtime_notifications = Notification.joins(:user).where(source: 'overtime', manager_id: current_user.id).select('notifications.*, users.name as user_name')
  end

  def edit
  end

  def new_page
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit      
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end

  def edit_basic_info
  end

  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :department, :password, :password_confirmation, :employee_number, :card_id, :basic_time, :work_start_time, :work_end_time)
  end

    def basic_info_params
      params.require(:user).permit(:department, :basic_time, :work_time)
    end

    # beforフィルター

# paramsハッシュからユーザーを取得します。
def set_user
  @user = User.find(params[:id])
end

# ログイン済みのユーザーか確認します。
def logged_in_user
  unless logged_in?
    store_location
    flash[:danger] = "ログインしてください。"
    redirect_to login_url
  end
end

# アクセスしたユーザーが現在ログインしているユーザーか確認します。
def correct_user
  redirect_to(root_url) unless current_user?(@user) || current_user.admin?|| current_user.manager?
end

# システム管理権限所有かどうか判定します。
  def admin_user
  redirect_to root_url unless current_user.admin?
  end
end