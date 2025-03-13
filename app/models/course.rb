class Course < ApplicationRecord
  belongs_to :school_class
  belongs_to :subject
  belongs_to :moment
  belongs_to :person
  has_many :examinations
  has_many :sections
end
