class User < ApplicationRecord
  ROLES = {admin: 1, doctor: 2, patient: 3}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  before_save { email.downcase! }
  after_create do |user_instance|
    if user_instance.patient?
      PatientInfo.new(user_id:user_instance.id).save
    elsif user_instance.doctor?
      DoctorInfo.new(user_id:user_instance.id).save
    end
  end
  validates :name, presence: true,
                   length: { maximum: 60 }
  validates :email, presence: true,
                    length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, presence: true,
                       length: { minimum: 8 }
  has_secure_password

  attr_accessor :remember_token

  def self.digest(string)
    cost = if ActiveModel::SecurePassword.min_cost
             BCrypt::Engine::MIN_COST
           else
             BCrypt::Engine.cost
           end
    BCrypt::Password.create(string, cost: cost)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def patient?
    self[:role] == ROLES[:patient]
  end

  def doctor?
    self[:role] == ROLES[:doctor]
  end

  def admin?
    self[:role] == ROLES[:admin]
  end

  def self.get_proper_role(role)
    ROLES[role.to_sym]
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def self.role_ok?(role)
    role == :patient.to_s or role == :doctor.to_s
  end

end
