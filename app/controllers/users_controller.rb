class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update]
  before_action :correct_user, only: [:edit, :update]

  def logged_in_user
    unless logged_in?
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user? @user
  end

  def show
    @user = User.find params[:id]
    if @user.patient?
      # base info about patient
      @patient = PatientInfo.find_by(user_id:@user.id)
      # info about doctors healing patient
      doctors_ids = DoctorPatient.where(patient_id: @patient.id).pluck(:doctor_id)
      @doctors = []
      unless doctors_ids.nil?
        doctors_ids.each do |doctor_id|
          doctor = DoctorInfo.find(doctor_id)
          user_id = doctor.user_id
          user = User.find(user_id)
          data = [user.name];
          unless doctor.position.nil?
            data.push doctor.position
          end
          title = data.join(', ')
          @doctors.push [title, user]
        end
      end
      # info about diseases
      @diseases = Disease.where(patient_id: @patient.id)
      # disease object for patient if current user is DOCTOR
      if current_user.doctor?
        @disease = Disease.new
        #@disease.patient_id = @patient.id
      end
    else
      @doctor = DoctorInfo.find_by(user_id:@user.id)
      patients_ids = DoctorPatient.where(doctor_id: @doctor.id).pluck(:patient_id)
      @patients = []
      unless patients_ids.nil?
        patients_ids.each do |patient_id|
          user_id = PatientInfo.find(patient_id).user_id
          user = User.find(user_id)
          @patients.push user
        end
      end
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
      @patient = PatientInfo.find_by(user_id:@user.id)
    else
      @doctor = DoctorInfo.find_by(user_id:@user.id)
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
    @patient = PatientInfo.find_by(user_id:@user.id)
    if @patient.update_attributes(filter_patient_params)
      flash.now[:success] = 'Account was successfully updated!'
    else
      flash.now[:danger] = 'Account was not updated. Please try again later!'
    end
    render 'edit'
  end

  def update_doctor
    @user = User.find(params[:id])
    @doctor = DoctorInfo.find(user_id:@user.id)
    if @doctor.update_attributes(filter_doctor_params)
      flash.now[:success] = 'Account was successfully updated!'
    else
      flash.now[:danger] = 'Account was not updated. Please try again later!'
    end
    render 'edit'
  end

  def add_disease
    patient = PatientInfo.find_by(params[:id])
    filtered_params = filter_disease_params
    filtered_params[:patient_id] = patient.id
    user = User.find(patient.user_id)
    @disease = Disease.new(filtered_params)
    if @disease.save
      flash.now[:success] = 'Disease was added to list'
    else
      flash.now[:danger] = 'No changes were performed. Please try again later!'
    end
    redirect_to user
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

  def filter_disease_params
    params.require(:disease).permit(:diagnosis,
                                    :symptoms,
                                    :treatment)
  end
end
