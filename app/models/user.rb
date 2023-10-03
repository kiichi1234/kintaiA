class User < ApplicationRecord
  require 'csv'
  has_many :attendances, dependent: :destroy
  has_many :managed_attendances, class_name: 'Attendance', foreign_key: 'manager_id'
  has_many :notifications, foreign_key: 'manager_id'
  # 「remember_token」という仮想の属性を作成します。
  attr_accessor :remember_token
  before_save { self.email = email.downcase }

  validates :name, presence: true, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  validates :department, length: { in: 2..50 }, allow_blank: true
  validates :basic_time, presence: true
  validates :work_time, presence: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # 渡された文字列のハッシュ値を返します。
  def User.digest(string)
    cost = 
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返します。
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def latest_notification_for(manager)
    Notification.where(manager_id: manager.id, user_id: self.id).order(updated_at: :desc).first
  end

  # CSVファイルからユーザー情報をインポートします。
  def self.import(file)
    error_messages = []
    successfully_imported_count = 0
    
    CSV.foreach(file.path, headers: true) do |row|
      user = User.find_by(email: row["email"])
      
      unless user # このユーザーがデータベースに存在しない場合
        user = User.new
        user.attributes = row.to_hash.slice(*csv_attributes)
        
        if user.save
          successfully_imported_count += 1
        else
          Rails.logger.error "Failed to create user #{user.email}: #{user.errors.full_messages.join(", ")}"
          error_messages << "Failed to create user #{user.email}: #{user.errors.full_messages.join(", ")}"
        end
      else
        Rails.logger.info "User with email #{user.email} already exists. Skipping."
      end
    end
    
    [successfully_imported_count, error_messages]
  end
  
  
  
  # CSVファイルから取得する属性を列挙します。
  def self.csv_attributes
    ["name", "email", "employee_number", "department", "card_id", "basic_time", "work_start_time", "work_end_time", "manager", "admin", "password"]
  end

  # 永続セッションのためハッシュ化したトークンをデータベースに記憶します。
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # トークンがダイジェストと一致すればtrueを返します。
  def authenticated?(remember_token)
    # ダイジェストが存在しない場合はfalseを返して終了します。
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ユーザーのログイン情報を破棄します。
  def forget
    update_attribute(:remember_digest, nil)
  end
end