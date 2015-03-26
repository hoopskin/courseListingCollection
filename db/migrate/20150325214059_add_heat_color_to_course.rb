class AddHeatColorToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :heatColor, :string
  end
end
