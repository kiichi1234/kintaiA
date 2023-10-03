class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :manager, class_name: "User", foreign_key: "manager_id"
  belongs_to :attendance

  STATUSES = ['申請中', '承認', '否認', 'なし'].freeze

  before_save :set_approved_at, if: -> { status_changed? && status == '承認' }

  private

  def set_approved_at
    self.approved_at = Time.current
  end
end
