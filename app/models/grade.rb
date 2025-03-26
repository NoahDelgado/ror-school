class Grade < ApplicationRecord
  include SoftDeletable

  belongs_to :examination
  belongs_to :person

  validates :value, presence: true,
                   numericality: {
                     greater_than_or_equal_to: 1,
                     less_than_or_equal_to: 6,
                     step: 0.5
                   }

  def self.valid_grades
    (1..6).step(0.5).to_a
  end
end
