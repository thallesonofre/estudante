# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @announcements = Announcement.visible_for(current_user).includes(:author).limit(5)

    if current_user.director? || current_user.staff?
      load_director_metrics
    elsif current_user.teacher?
      load_teacher_metrics
    elsif current_user.student?
      load_student_metrics
    end
  end

  private

  def load_director_metrics
    @total_students = User.student.count
    @total_teachers = User.teacher.count
    @total_staff = User.staff.count
    @total_classrooms = Classroom.count
    @total_subjects = Subject.count

    all_attendances = Attendance.all
    @overall_attendance_rate = if all_attendances.any?
      present_count = all_attendances.where(status: [ :present, :late, :justified ]).count
      ((present_count.to_f / all_attendances.count) * 100.0).round(1)
    else
      100.0
    end

    @bimester_averages = [ 1, 2, 3, 4 ].index_with do |bim|
      scores = Assessment.where(bimester: bim)
      scores.any? ? scores.average(:score).to_f.round(2) : 0.0
    end

    @overall_grade_average = Assessment.any? ? Assessment.average(:score).to_f.round(2) : 0.0

    # Performance per classroom & attention radar
    @classroom_stats = Classroom.includes(:students, :subjects).ordered.map do |classroom|
      student_ids = classroom.students.map(&:id)
      subject_ids = classroom.subjects.map(&:id)

      avg_score = if student_ids.any? && subject_ids.any?
        Assessment.where(student_id: student_ids, subject_id: subject_ids).average(:score).to_f.round(2)
      else
        0.0
      end

      att_records = Attendance.where(student_id: student_ids, subject_id: subject_ids)
      att_rate = if att_records.any?
        ((att_records.where(status: [ :present, :late, :justified ]).count.to_f / att_records.count) * 100.0).round(1)
      else
        100.0
      end

      {
        classroom: classroom,
        students_count: student_ids.size,
        subjects_count: subject_ids.size,
        average_score: avg_score,
        attendance_rate: att_rate
      }
    end

    # Students needing pedagogical attention
    @attention_students = []
    User.student.includes(:classrooms).ordered.each do |student|
      classroom = student.current_classroom
      next unless classroom

      subjects = classroom.subjects
      next if subjects.empty?

      calcs = subjects.map { |sub| AcademicCalculatorService.new(student: student, subject: sub) }
      avg_annual = calcs.filter_map(&:annual_average)
      overall_student_avg = avg_annual.any? ? (avg_annual.sum / avg_annual.size.to_f).round(2) : nil
      total_absences = calcs.sum(&:absences_count)
      min_att_rate = calcs.map(&:attendance_rate).min || 100.0

      if (overall_student_avg && overall_student_avg < 6.0) || min_att_rate < 80.0
        @attention_students << {
          student: student,
          classroom: classroom,
          average: overall_student_avg || 0.0,
          absences: total_absences,
          min_attendance_rate: min_att_rate
        }
      end
    end
  end

  def load_teacher_metrics
    @subjects = current_user.taught_subjects.includes(:classroom, :students).ordered
    @total_students = @subjects.flat_map(&:students).uniq.size
    @total_assessments = Assessment.where(subject_id: @subjects.map(&:id)).count
    @recent_attendances = Attendance.where(subject_id: @subjects.map(&:id))
                                    .select(:subject_id, :attended_on, :bimester, :lesson_topic)
                                    .distinct
                                    .order(attended_on: :desc)
                                    .limit(6)

    @subject_summaries = @subjects.map do |subject|
      students = subject.classroom.students
      calcs = students.map { |st| AcademicCalculatorService.new(student: st, subject: sub = subject) }
      avgs = calcs.filter_map(&:annual_average)
      att_rates = calcs.map(&:attendance_rate)

      {
        subject: subject,
        students_count: students.size,
        class_average: avgs.any? ? (avgs.sum / avgs.size.to_f).round(2) : 0.0,
        attendance_rate: att_rates.any? ? (att_rates.sum / att_rates.size.to_f).round(1) : 100.0
      }
    end
  end

  def load_student_metrics
    @classroom = current_user.current_classroom
    @subjects = current_user.enrolled_subjects
    @subject_reports = @subjects.map do |subject|
      AcademicCalculatorService.new(student: current_user, subject: subject).summary
    end

    avgs = @subject_reports.filter_map { |r| r[:annual_average] }
    @global_annual_average = avgs.any? ? (avgs.sum / avgs.size.to_f).round(2) : 0.0
    @total_absences = @subject_reports.sum { |r| r[:absences_count] }
    @total_classes = @subject_reports.sum { |r| r[:total_classes] }
    @global_attendance_rate = if @total_classes.positive?
      (((@total_classes - @total_absences).to_f / @total_classes) * 100.0).round(1)
    else
      100.0
    end
  end
end
