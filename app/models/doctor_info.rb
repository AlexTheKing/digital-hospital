class DoctorInfo < ApplicationRecord
  def has_nil?
    self[:birthday].nil? or self[:position].nil?
  end

  def error_messages
    messages = []
    if self[:birthday].nil?
      messages += ["Date of birth"]
    end
    if self[:position].nil?
      messages += ["Position"]
    end
    messages
  end

  def get_title(user)
    data = [user.name]
    unless self[:position].nil?
      data.push self[:position]
    end
    data.join(', ')
  end
end
