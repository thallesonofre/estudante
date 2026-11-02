# frozen_string_literal: true

class CreateSchoolStructure < ActiveRecord::Migration[8.1]
  def change
    create_table :classrooms do |t|
      t.string :name, null: false
      t.integer :academic_year, null: false, default: 2026
      t.string :shift, null: false, default: "Matutino"
      t.string :room_number
      t.string :grade_level, null: false, default: "Ensino Médio"

      t.timestamps
    end

    create_table :subjects do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.integer :workload_hours, null: false, default: 80
      t.references :classroom, null: false, foreign_key: true
      t.references :teacher, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :subjects, :code, unique: true

    create_table :enrollments do |t|
      t.references :student, null: false, foreign_key: { to_table: :users }
      t.references :classroom, null: false, foreign_key: true
      t.string :status, null: false, default: "Ativo"
      t.date :enrolled_on, null: false

      t.timestamps
    end

    add_index :enrollments, [ :student_id, :classroom_id ], unique: true

    create_table :assessments do |t|
      t.references :student, null: false, foreign_key: { to_table: :users }
      t.references :subject, null: false, foreign_key: true
      t.integer :bimester, null: false
      t.string :title, null: false
      t.string :category, null: false, default: "Prova"
      t.decimal :score, precision: 5, scale: 2, null: false, default: 0.0
      t.decimal :max_score, precision: 5, scale: 2, null: false, default: 10.0
      t.date :evaluated_on, null: false
      t.text :feedback

      t.timestamps
    end

    add_index :assessments, [ :student_id, :subject_id, :bimester ]

    create_table :attendances do |t|
      t.references :student, null: false, foreign_key: { to_table: :users }
      t.references :subject, null: false, foreign_key: true
      t.date :attended_on, null: false
      t.integer :bimester, null: false, default: 1
      t.integer :status, null: false, default: 0
      t.string :lesson_topic
      t.string :justification

      t.timestamps
    end

    add_index :attendances, [ :student_id, :subject_id, :attended_on ], unique: true

    create_table :announcements do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.integer :priority, null: false, default: 0
      t.integer :audience, null: false, default: 0
      t.boolean :pinned, null: false, default: false
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.datetime :published_at, null: false

      t.timestamps
    end
  end
end
