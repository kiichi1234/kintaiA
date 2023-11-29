class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :manager, class_name: "User", foreign_key: "manager_id"
  belongs_to :attendance

  STATUSES = ['申請中', '承認', '否認', 'なし'].freeze

  before_save :set_approved_at, if: -> { status_changed? && status == '承認' }

  def overtime_hours
    # 残業終了時間の計算
    end_time = self.scheduled_end
    end_time += 24.hours if self.next_day

    # 残業時間の計算（勤務終了時間との差）
    overtime = end_time - self.user.work_end_time

    # 残業時間のフォーマット
    Time.at(overtime).utc.strftime("%-H:%M")
  end

  private

  def set_approved_at
    self.approved_at = Time.current
  end
end
