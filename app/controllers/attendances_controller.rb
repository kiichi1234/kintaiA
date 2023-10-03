require 'csv'
class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month

  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"

  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end

  def edit_one_month
    @superiors = User.where(manager: true).pluck(:name, :id)
  end

  def update_one_month
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.editing = true
  
        if attendance.update_attributes(item)
          # Notificationを作成
          Notification.create(
            user_id: current_user.id,
            manager_id: item[:manager_id],
            attendance_id: attendance.id
          )
        else
          flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
          redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
        end
      end
    end
  
    flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  


  def download
      @user = User.find(params[:id])
      attendances = @user.attendances
      month = params[:date] ? Date.parse(params[:date]) : Date.today
      attendances = @user.attendances.where(worked_on: month.beginning_of_month..month.end_of_month)
    
  
    csv_data = CSV.generate do |csv|
      csv << ["日付", "曜日", "出勤時間", "退勤時間"]
      attendances.each do |attendance|
        date = attendance.worked_on
        day_of_week = case date.wday
                      when 0 then '日'
                      when 1 then '月'
                      when 2 then '火'
                      when 3 then '水'
                      when 4 then '木'
                      when 5 then '金'
                      when 6 then '土'
                      end
        if attendance.started_at
           rounded_minutes_for_start = ((attendance.started_at.min.to_i / 15) * 15) % 60
           start_time = attendance.started_at.change(min: rounded_minutes_for_start).strftime('%H:%M')
          else
            start_time = nil
          end
        if attendance.finished_at
          rounded_minutes = ((attendance.finished_at.min.to_i / 15) * 15) % 60
          end_time = attendance.finished_at.change(min: rounded_minutes).strftime('%H:%M')  # 'HH:MM' 形式, 15分単位に丸め
        else
          end_time = nil
        end
        csv << [date, day_of_week, start_time, end_time]
      end
    end

    send_data(csv_data, filename: "【勤怠一覧】#{ @user.name }_#{ month.strftime('%Y-%m') }.csv")
  end
  
  def attendance_confirmation
  end
  



  def present_employees
    @present_employees =User.joins(:attendances)
    .where.not(attendances: { 
      started_at: nil
    })
    .where(attendances: { 
      finished_at: nil,
      worked_on: Date.today 
    })
    
  end
  
  private

    # 1ヶ月分の勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :next_day, :manager_id])[:attendances]
    end
    

    # beforeフィルター

    # 管理権限者、または現在ログインしているユーザーを許可します。
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end  
    end
end