class AddHistenrlToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :histenrl, :string
  end
end
