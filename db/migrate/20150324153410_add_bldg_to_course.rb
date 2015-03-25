class AddBldgToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :bldg, :string
  end
end
