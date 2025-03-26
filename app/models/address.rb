class Address < ApplicationRecord
  has_many :person

  def to_s
    "#{street} #{number}, #{zip} #{town}"
  end
end
