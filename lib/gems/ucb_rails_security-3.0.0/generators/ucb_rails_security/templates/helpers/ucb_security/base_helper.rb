module UcbSecurity::BaseHelper
  
  def role_checkbox
    raise "This method has been deprecated"
  end 
  
  def in_user_table?
    id_from_uid ? true : false
  end
  
  def id_from_uid
    @user_uids[@entry.uid]
  end
  
  def display_message
    return "<div class='error'>#{flash[:error]}</div>" if flash[:error]
    return "<div class='notice'>#{flash[:notice]}</div>" if flash[:notice]
  end
  
  def title(title)
    @title = title
  end
end