module SessionsHelper

  def sign_in(user)
    cookies.permanent.signed[:remember_token] = [user.id, user.salt]
    user.update_attribute(:last_login_at, Time.zone.now)
    update_activity_time
    #session[:last_movement] = Time.now
    self.current_user = user
  end
  
  def sign_out
    cookies.delete(:remember_token)
    self.current_user = nil
  end

  def current_user=(user)
    @current_user = user
  end
  
  def current_user
    @current_user ||= user_from_remember_token
  end
  
  
  def signed_in?
    if current_user.nil? 
       return false
     else
      update_activity_time
      true
    end
  end

  def is_admin?
    current_user.admin?
  end


  def login_required
    return if signed_in?
    respond_to do |format|
      format.html do
        puts "access denied"
        deny_access
      end
      format.any(:json, :xml) do
        if user = authenticate_from_basic_auth
          puts "found user from basic id=#{user.id}"
          session[:user_id] = user.id
          user.update_attribute(:mobile_last_login_at, Time.zone.now)
        else
          puts "asked for auth"
          request_http_basic_authentication 'Web Password'
        end
      end
    end
  end
  
  def authenticate_from_basic_auth
    authenticate_with_http_basic do |login, password|
      user = User.authenticate(login, password)
      if !user
        user = User.authenticate_with_email(login,password)
      end
      user
    end
  end
  


  def authenticate
    deny_access unless signed_in?
  end

  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end
  
 # def deny_access
 #   store_location
 #   redirect_to signin_path, :notice => "Please sign in to access this page."
 # end

  def deny_access(msg = nil)
    msg ||= "Please sign in to access this page."
    flash[:notice] ||= msg
    respond_to do |format|
      format.html {
        store_location
        redirect_to signin_url
      }
      format.js {
        store_location request.referer
        render 'sessions/redirect_to_login', :layout=>false
      }
    end
  end

  def authenticate
    deny_access unless signed_in?
  end

  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end
  
  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end

  def current_user?(user)
    user == current_user
  end

  private
  
    def update_activity_time
      session[:expires_at] = 30.minutes.from_now
    end

    def user_from_remember_token
      User.authenticate_with_salt(*remember_token)
    end
    
    def remember_token
      cookies.signed[:remember_token] || [nil,nil]
    end

    def store_location(location=nil)
      if location 
        session[:return_to] = location
      else
        session[:return_to] = request.fullpath
      end
    end

     def clear_return_to
      session[:return_to] = nil
    end

 
end
