class NotificationsController < ApplicationController
  def batch_update
    selected_notifications = notification_params.values.select { |data| data[:is_active] == 'true' }

    if selected_notifications.empty?
      flash[:danger] = "変更欄にチェックを付けてください。"
      redirect_to user_url(id: current_user.id, date: params[:date]) and return
    end

    notification_params.each do |id, notification_data|
      if notification_data[:is_active] == 'true'
        notification = Notification.find(id)
        notification.update(notification_data) # ここでexcept(:is_active)を取り除く
      end
    end
    flash[:success] = "ユーザーからの申請を更新しました。"
    redirect_to user_url(id: current_user.id, date: params[:date])
  end
      
  private
      
  def notification_params
    params.require(:notifications).permit!
  end
end
