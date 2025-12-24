module ApplicationHelper
  def user_initials(user)
    return "U" unless user
    
    if user.email.present?
      email_name = user.email.split('@').first
      
      if email_name.include?('.') || email_name.include?('_')
        parts = email_name.split(/[._]/)
        if parts.length >= 2
          "#{parts.first[0]}#{parts.last[0]}".upcase
        else
          email_name[0..1].upcase
        end
      else
        email_name[0..1].upcase
      end
    else
      "U"
    end
  end
end