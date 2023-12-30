class Attendance < ApplicationRecord
  belongs_to :user
  belongs_to :manager, class_name: 'User', foreign_key: 'manager_id', optional: true
  has_many :notifications


  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }

  # 出勤時間が存在しない場合、退勤時間は無効
  validate :finished_at_is_invalid_without_a_started_at
  # 出勤・退勤時間どちらも存在する時、出勤時間より早い退勤時間は無効
  validate :started_at_than_finished_at_fast_if_invalid
  # 退勤時間が存在しない場合、出勤時間は無効（勤怠編集画面からの更新の場合のみ適用）
  validate :started_at_is_invalid_without_a_finished_at, if: :editing

  attr_accessor :editing

  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end

  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present? && !next_day
      errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at
    end
  end
  
  def started_at_is_invalid_without_a_finished_at
    if editing || worked_on != Date.today
      errors.add(:finished_at, "が必要です") if started_at.present? && finished_at.blank?
    end
  end
end
