class Examination < ApplicationRecord
  include SoftDeletable

  belongs_to :course
  has_many :grades
  accepts_nested_attributes_for :grades, allow_destroy: true
end
