class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :college
      t.string :number
      t.string :title
      t.string :credits
      t.string :courseId
      t.string :sect
      t.string :gradeMeth
      t.string :days
      t.string :days2
      t.string :time
      t.string :time2
      t.string :dates
      t.string :dates2
      t.string :instructor
      t.string :instructor2
      t.string :size
      t.string :enrl
      t.string :status
      t.string :addlNotes
      t.string :semester
      t.string :session
      t.string :prereqs
      t.string :offered

      t.timestamps null: false
    end
  end
end
