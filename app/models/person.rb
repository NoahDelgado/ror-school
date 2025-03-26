class Person < ApplicationRecord
  include SoftDeletable

  belongs_to :address
  has_many :school_classes
  has_many :courses
  has_many :grades
  belongs_to :status
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  scope :not_deleted, -> { where(deleted_at: nil) }

  def full_name
    [ firstname, lastname ].compact.join(" ").presence || email
  end
end
