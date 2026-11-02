# frozen_string_literal: true

module ApplicationHelper
  def nav_active_class(paths)
    Array(paths).any? { |p| request.path == p || (p != "/" && request.path.start_with?(p)) } ? "active" : ""
  end

  def format_grade(value)
    return "—" if value.nil?

    number_with_precision(value, precision: 2, separator: ",")
  end

  def grade_color_class(value)
    return "text-muted" if value.nil?
    return "grade-high" if value.to_f >= 8.0
    return "grade-pass" if value.to_f >= 6.0
    return "grade-warn" if value.to_f >= 4.0

    "grade-low"
  end

  def format_br_date(date)
    return "—" if date.blank?

    date.strftime("%d/%m/%Y")
  end

  def format_br_datetime(dt)
    return "—" if dt.blank?

    dt.strftime("%d/%m/%Y às %H:%M")
  end
end
