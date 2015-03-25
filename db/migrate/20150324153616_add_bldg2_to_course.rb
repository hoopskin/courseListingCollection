class AddBldg2ToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :bldg2, :string
  end
end
