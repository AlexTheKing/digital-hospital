class UsersController < ApplicationController
  def show
    @user = User.find params[:id]
    if @user.patient?
      @patient = PatientInfo.find(@user.id)
    else
      @doctor = DoctorInfo.find(@user.id)
    end
  end

  def new
    @user = User.new
  end

  def create
    role_s = get_role_from_params
    if User.role_ok?(role_s)
      create_params = filter_params_all
      create_params[:role] = User.get_proper_role role_s
      @user = User.new(create_params)
      if @user.save
        log_in @user
        flash[:success] = 'Your account was successfully created! Now you are signed in!'
        redirect_to @user
      else
        render 'new'
      end
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
    if @user.patient?
      @patient = PatientInfo.find(@user.id)
    else
      @doctor = DoctorInfo.find(@user.id)
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.authenticate(get_old_pass)
      if @user.update_attributes(filter_params_all)
        flash.now[:success] = 'Account was successfully updated!'
      else
        flash.now[:danger] = 'Account was not updated. Please try again later!'
      end
    else
      flash.now[:danger] = 'Wrong password!'
    end
    render 'edit'
  end

  def update_patient
    @user = User.find(params[:id])
    @patient = PatientInfo.find(@user.id)
    if @patient.update_attributes(filter_patient_params)
      flash.now[:success] = 'Account was successfully updated!'
    else
      flash.now[:danger] = 'Account was not updated. Please try again later!'
    end
    render 'edit'
  end

  def update_doctor
    @user = User.find(params[:id])
    @doctor = DoctorInfo.find(params[:id])
    if @doctor.update_attributes(filter_doctor_params)
      flash.now[:success] = 'Account was successfully updated!'
    else
      flash.now[:danger] = 'Account was not updated. Please try again later!'
    end
    render 'edit'
  end

  private

  def filter_params_all
    params.require(:user).permit(:name,
                                 :email,
                                 :password,
                                 :password_confirmation)
  end

  def get_old_pass
    params.require(:user).permit(:old_password)[:old_password]
  end

  def get_role_from_params
    params.require(:user).permit(:role)[:role]
  end

  def filter_patient_params
    params.require(:patient_info).permit(:birthday,
                                         :address)
  end

  def filter_doctor_params
    params.require(:doctor_info).permit(:birthday,
                                        :position)
  end
end
