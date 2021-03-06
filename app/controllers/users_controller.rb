class UsersController < ApplicationController
  before_action :logged_in_user, only: [:show, :edit, :update]
  before_action :correct_user, only: [:edit, :update]
  before_action :is_doctor, only: [:show_patients]
  before_action :show_foreign, only: [:show]

  def show_foreign
    user = current_user
    if user.id != params[:id].to_i and user.patient?
      if DoctorInfo.exists? params[:id]
        patient_id = PatientInfo.find_by(user_id: user.id).id
        doctors_ids = DoctorPatient.where(patient_id: patient_id).pluck(:doctor_id)
        doctor_id = DoctorInfo.find_by(user_id:params[:id]).id
        unless doctors_ids.include? doctor_id
          flash[:danger] = "You can see only your doctors' profiles"
          redirect_to user
        end
      else
        flash[:danger] = "You have no access to see this profile"
        redirect_to user
      end
    end
  end

  def is_doctor
    unless current_user.doctor?
      flash[:danger] = "This information accessible only for doctors"
      redirect_to current_user
    end
  end

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
          title = doctor.get_title user
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
          patient = PatientInfo.find(patient_id)
          user = User.find(patient.user_id)
          title = patient.get_title user
          @patients.push [title, user]
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
    patient = PatientInfo.find(params[:id])
    filtered_params = filter_disease_params
    filtered_params[:patient_id] = params[:id]
    user = User.find(patient.user_id)
    @disease = Disease.new(filtered_params)
    doctor = DoctorInfo.find_by(user_id: current_user.id)
    if DoctorPatient.where(doctor_id: doctor.id, patient_id: patient.id).empty?
      doctor_patient = DoctorPatient.new(doctor_id: doctor.id, patient_id: patient.id)
      if doctor_patient.save and @disease.save
        flash.now[:success] = 'Disease was added to list'
      else
        flash.now[:danger] = 'No changes were performed. Please try again later!'
      end
    else
      if @disease.save
        flash.now[:success] = 'Disease was added to list'
      else
        flash.now[:danger] = 'No changes were performed. Please try again later!'
      end
    end
    redirect_to user
  end

  def show_patients
    @patients = []
    PatientInfo.all.each do |patient|
      user = User.find(patient.user_id)
      title = patient.get_title user
      @patients.push [title, user]
    end
    @patients = @patients.paginate(page: params[:page])
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
