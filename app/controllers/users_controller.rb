class UsersController < ApplicationController
  before_action :authenticate_person!
  before_action :ensure_dean!
  before_action :set_user, only: %i[ show edit update destroy ]

  # GET /users
  def index
    # Search, filter, and sort functionality without ransack
    @users = Person.not_deleted

    # Search functionality
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @users = @users.where(
        "email LIKE ? OR firstname LIKE ? OR lastname LIKE ? OR username LIKE ?",
        search_term, search_term, search_term, search_term
      )
    end

    # Filter by type
    if params[:type].present?
      @users = @users.where(type: params[:type])
    end

    # Sorting
    sort_column = params[:sort].present? ? params[:sort] : "created_at"
    sort_direction = params[:direction].present? ? params[:direction] : "desc"

    # Whitelist allowed columns to sort by
    allowed_columns = %w[type firstname lastname email username created_at]
    sort_column = "created_at" unless allowed_columns.include?(sort_column)

    # Whitelist allowed directions
    sort_direction = %w[asc desc].include?(sort_direction) ? sort_direction : "desc"

    @users = @users.order("#{sort_column} #{sort_direction}")

    # Simple pagination
    @total_count = @users.count
    @per_page = 10
    @page = params[:page].to_i > 0 ? params[:page].to_i : 1
    @total_pages = (@total_count.to_f / @per_page).ceil
    @users = @users.limit(@per_page).offset((@page - 1) * @per_page)
  end

  # GET /users/1
  def show
  end

  # GET /users/new
  def new
    @user = Person.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  def create
    # Create the address first
    address = create_or_update_address(Address.new)

    # Create the proper user type based on type parameter
    @user = user_class.new(user_params)
    @user.address = address

    if @user.save
      redirect_to users_path, notice: "User was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    # Update the address
    create_or_update_address(@user.address)

    if @user.update(user_params)
      redirect_to users_path, notice: "User was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.soft_delete
    redirect_to users_path, notice: "User was successfully archived."
  end

  private
    def set_user
      @user = Person.find(params[:id])
    end

    def user_params
      params.require(:person).permit(
        :email, :password, :password_confirmation,
        :username, :firstname, :lastname,
        :phone_number, :iban, :type, :status_id
      )
    end

    def create_or_update_address(address)
      # Get address params from form
      address_params = params[:address]

      if address_params
        address.street = address_params[:street]
        address.number = address_params[:number]
        address.zip = address_params[:zip]
        address.town = address_params[:town]
        address.save
      end

      address
    end

    def ensure_dean!
      unless current_person.is_a?(Dean)
        redirect_to root_path, alert: "You are not authorized to manage users."
      end
    end

    def user_class
      case params[:person][:type]
      when "Student"
        Student
      when "Teacher"
        Teacher
      when "Dean"
        Dean
      when "Administrator"
        Administrator
      else
        Person
      end
    end
end
