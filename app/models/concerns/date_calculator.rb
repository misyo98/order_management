module DateCalculator
  def too_far_apart?(start_date, end_date, valid_range, work_days)
    days_between =
      if work_days
        work_days_between(start_date, end_date)
      else
        (end_date.to_date - start_date.to_date).to_i
      end
    days_between > valid_range
  end

  private

  def work_days_between(date1, date2)
    work_days = 0
    date = date2
    while date > date1
     work_days = work_days + 1 unless date.saturday? or date.sunday?
     date = date - 1.day
    end
    work_days
  end
end
