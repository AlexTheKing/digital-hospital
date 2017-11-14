class PatientInfo < ApplicationRecord
  def has_nil?
    self[:birthday].nil? or self[:address].nil?
  end

  def error_messages
    messages = []
    if self[:birthday].nil?
      messages += ["Date of birth"]
    end
    if self[:address].nil?
      messages += ["Address"]
    end
    messages
  end

  def get_title(user)
    data = [user.name]
    unless self[:birthday].nil?
      data.push self[:birthday]
    end
    data.join(', ')
  end
end
