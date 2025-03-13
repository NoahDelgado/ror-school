class Person < ApplicationRecord
  belongs_to :address
  has_many :school_classes
  has_many :courses
  has_many :grades
  belongs_to :status
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
