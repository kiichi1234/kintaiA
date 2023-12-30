class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :manager, class_name: "User", foreign_key: "manager_id"
  belongs_to :attendance

  STATUSES = ['申請中', '承認', '否認', 'なし'].freeze

  before_save :set_approved_at, if: -> { status_changed? && status == '承認' }
  before_save :set_default_status, if: -> { status.blank? }

  def overtime_hours
    # 残業終了時間の計算
    end_time = self.scheduled_end
    # 'scheduled_end' が 'Time' オブジェクトの場合は、日付情報を追加
    end_time = end_time.change(day: self.user.work_end_time.day, 
                               month: self.user.work_end_time.month, 
                               year: self.user.work_end_time.year) 
    end_time += 24.hours if self.next_day
  
    # 残業時間の計算（勤務終了時間との差）
    overtime = end_time - self.user.work_end_time
  
    # 残業時間が負の場合、マイナス記号を付けてフォーマット
    if overtime.negative?
      # 負の秒数を時間と分に変換してフォーマット
      total_minutes = overtime.abs / 60
      hours = total_minutes / 60
      minutes = total_minutes % 60
      format("-%d:%02d", hours, minutes)
    else
      # 正の残業時間をフォーマット
      Time.at(overtime).utc.strftime("%-H:%M")
    end
  end

  private

  def set_approved_at
    self.approved_at = Time.current
  end

  def set_default_status
    self.status = '申請中'
  end

  def overtime_params
    params.require(:notification).permit(:scheduled_end, :content ) 
  end

end
