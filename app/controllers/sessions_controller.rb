class SessionsController < ApplicationController
  def new

  end

  def create
    email = params[:session][:email].downcase
    pass = params[:session][:password]
    user = User.find_by(email: email)
    if user && user.authenticate(pass)
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_to user
    else
      flash.now[:danger] = "Wrong email or password. Please try again"
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
