class AddSectionToSchoolClasses < ActiveRecord::Migration[8.0]
  def change
    add_reference :school_classes, :section, null: false, foreign_key: true
  end
end
