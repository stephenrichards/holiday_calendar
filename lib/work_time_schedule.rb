
class WorkTimeSchedule
    
    # Instantiates a WorkTimeSchedule object using the named HolidayCalendar object, and the default start and end times of the working day.
    #
    # Parameters:
    # * calendar: A valid HolidayCalendar object which describes weekends, public holidays
    # * start_hh: the start time hours
    # * start_mm: the start time minutes
    # * end_hh: the end time hours
    # * end_mm: the end time minutes
    #
    # Example:
    #
    #        cal = HolidayCalendar.new(:uk_en)                      # use the UK English Holiday Calendar
    #        wts = WorkTimeSchedule.new(cal, 9, 0, 17, 30)          # instantiate the Work Time Schedule with work hours 09:00 - 17:30
    #                                                               # for all days designated as work days
    #
    def initialize(calendar, start_hh, start_mm, end_hh, end_mm)
        @calendar = calendar
        @default_start_time = WorkTime.new(start_hh, start_mm)
        @default_end_time = WorkTime.new(end_hh, end_mm)
        @days = Array.new
        (0..6).each do |day_no|
            if @calendar.weekend_day_number?(day_no)
                @days[day_no] = WorkDay.new(nil, nil)
            else
                @days[day_no] = WorkDay.new(@default_start_time, @default_end_time)
            end
        end
    end
    
    
    # Returns the WorkDay object for the specified date
    #
    # Parameters:
    # * value: can either be a DateTime object, or a day number
    #
    def workday(value)
        if value.is_a? DateTime
            day_number = to_day_number(date_time)
        elsif value.is_a? Fixnum
            day_number = value
        else
            raise "Invalid type specified: must be a DateTime or Fixnum"
        end
       @days[day_number] 
    end
    
    
    
    # Overrides the start and end times of the specified working day.  This can be used to, for example, set an
    # earlier finish date for Fridays, or to set working times for weekends.
    #
    # Parameters:
    # * day_number: A number in the range 0 (Sunday) to 6 (Saturday) defining which day is to be overridden
    # * start_time: A 3 or 4 digit number representing hours and minutes of start of work time (e.g. 930 = 9:30 am)
    # * end_time: A 3 or 4 digit number representing hours and minutes of end of work time (e.g. 1730 = 5:30 pm)
    #
    def set_day(day_number, start_time, end_time)
        raise 'Day number must be in range 0-6' if day_number < 0 || day_number > 6
        raise 'Start Time must be a WorkTime object' unless start_time.instance_of?(WorkTime)
        raise 'End Time must be a WorkTime object' unless end_time.instance_of?(WorkTime)
        @days[day_number] = WorkDay.new(start_time, end_time)
    end
    
    
    # Returns true if the specified DateTime object is during working hours
    #
    def working_time?(date_time)
        return false unless working_day?(date_time)
        work_time = to_work_time(date_time)
        work_day = @days[to_day_num(date_time)]
        return work_day.includes?(work_time)
    end
    
    
    
    # Returns true if the specified date is a working day.
    #
    def working_day?(date_time)
        raise "Parameter must be a date_time object: id #{date_time.class}" unless date_time.is_a?(DateTime)
        return false if  @calendar.public_holiday?(date_time)
        work_day = @days[to_day_num(date_time)]
        return false unless work_day.working_day?
        return true
    end
    
    
    # Returns a DateTime object representing the start of the working day in relation to date_time.  If date_time is
    # not a working day, or after the end of the working day, then the start of the next working day is returned,  
    # otherwise the start of the working day.
    #
    def start_of_day(date_time)
        unless working_day?(date_time)
            return start_of_day(next_working_day(date_time))
        end
        work_time = to_work_time(date_time)
        work_day = to_work_day(date_time)
        if work_time > work_day.end_time
            return start_of_day(next_working_day(to_modified_date_time(date_time, WorkTime.new(0, 0))))
        end
        return to_modified_date_time(date_time, work_day.start_time)
    end



    
    
    
    # Returns a DateTime object representing the end of the working day in relation date_time.  If date_time is 
    # not a working day, the end of the previous working day is returned.
    #
    def end_of_day(date_time)
        unless working_day?(date_time)
            return end_of_day(previous_working_day(date_time))
        end
        work_time = to_work_time(date_time)
        work_day = to_work_day(date_time)
        if work_time < work_day.start_time
            return end_of_day(previous_working_day(to_modified_date_time(date_time, WorkTime.new(12, 0))))
        end
        return to_modified_date_time(date_time, work_day.end_time)        
        
    end
    
    
    
    # returns a DateTime object for the same time on the next working day
    #
    def next_working_day(date_time)
        date_time = date_time + 1
        while !working_day?(date_time)
            date_time = date_time + 1
        end
        date_time
    end
        
    
    # returns a DateTime object for the same time on the previous working day
    #
    def previous_working_day(date_time)
        date_time = date_time - 1
        while !working_day?(date_time)
            date_time = date_time - 1
        end
        date_time
    end
    
    
    
    
    
    
    # returns a DateTime object as follows:
    # * if date_time is not a working day, the start time of the next working day is returned
    # * if date_time is before the start time of a working day, the start time is returned
    # * if date_time is after the end of the working day, the start time of the next working day is returned
    # * otherwise, the date_time is returned unchanged
    #
    def time(date_time)
        unless working_day?(date_time)
            return start_of_day(next_working_day(date_time))
        end
        work_time = to_work_time(date_time)
        work_day = to_work_day(date_time)
        if work_time < work_day.start_time
            return start_of_day(date_time)
        elsif work_time > work_day.end_time
            return start_of_day(next_working_day(to_modified_date_time(date_time, WorkTime.new(0, 0))))
        else
            return date_time
        end
    end
    
    
    # returns a date_time object as follows:
    # * if date_time is during working hours, returns date_time unmodified
    # * if date_time is after working hours, returns the end of working time
    # * if date_time is before working hours, returns the start of the working time
    # * if date_time is on a non_working day, returns the end of working time for the previous day
    #
    def time_or_end_of_day(date_time)
        wt = to_work_time(date_time)
        work_day = get_work_day(date_time)
        if wt > work_day.end_time
            return end_of_day(date_time)
        elsif wt < work_day.start_time
            return start_of_day(date_time)
        else
            return date_time
        end
    end
        
        
        
    # Returns the total number of minutes in a full working day for the given DateTime
    def total_working_minutes(date_time)
        return 0 unless working_day?(date_time)
        work_day = get_work_day(date_time)
        work_day.total_minutes
    end
    
    
    
    # Returns the time in minutes between the working start time for the day, and the specified date_time.
    # If the date refers to a non-working day, or the time is before the start of the working day, 0 is returned.
    # If the date refers to a time after the working day, total_working_minutes is returned.
    #
    def minutes_worked_today_until(date_time)
        return 0 unless working_day?(date_time)
        work_day = get_work_day(date_time)
        t = to_work_time(date_time)
        return 0 if t < work_day.start_time
        return total_working_minutes(date_time) if t > work_day.end_time
        end_time = to_work_time(date_time)
        end_time - work_day.start_time
    end
    
    
    
    
    
    
    # Shorthand for WorkingTimeSchedule#time(DateTime.now)
    #
    def now
        time(DateTime.now)
    end
    
    
    ############# this needs to be thoroughly testeed, including times both in ourt of ohurs, etc
    
    # Returns the number of working minutes that have elapsed between the two times
    def elapsed_minutes(start_time, end_time)
        raise "End time must be after start time" unless start_time < end_time
        working_start_time = time(start_time)
        working_end_time = time_or_end_of_day(end_time)
        
        if year_day(working_start_time) == year_day(working_end_time)           # both times are on the same day
            return to_work_time(working_end_time) - to_work_time(working_start_time)
        end
        
        # elapsed time spans more than one day
        
        
        
        
        minutes = minutes_to_end_of_day(working_start_time)
        while year_day(working_start_time) < year_day(working_end_time) 
            working_start_time = next_working_day(working_start_time)
            if year_day(working_start_time) < year_day(working_end_time)
                minutes += total_working_minutes(working_start_time)
            else
                minutes += minutes_worked_today_until(working_end_time)
            end
        end
        minutes
    end

    
    
    # Translate method names sunday, monday etc to set_day
    #
    def method_missing(method, *params)
      valid_methods = [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]
      unless valid_methods.include?(method)
          raise "Method #{method.inspect} not recognised"
      end
      day_number = valid_methods.index(method)
      set_day(day_number, params[0], params[1])
    end
    
    
    
    
    private
    # Returns the WorkDay object for the specified date
    #
    def get_work_day(date_time)
      day_num = to_day_num(date_time)
      @days[day_num]
    end
    
    
    
    # Returns the number of minutes from the date_time to the end of the working day on that date.
    #
    def minutes_to_end_of_day(date_time)
        wt = to_work_time(date_time)
        day_num = to_day_num(date_time)
        work_end_time = @days[day_num].end_time
        return work_end_time - wt
    end
    
    
    
    # returns representation of date as an integer in form YYYYDDD
    #
    def year_day(date_time)
        (date_time.year * 1000) + date_time.yday
    end
    
    
    
    # returns the day number for the given DateTime object
    #
    def to_day_num(date_time)
        date_time.strftime('%w').to_i
    end
    
    # returns a WorkDay object for the specified date
    #
    def to_work_day(date_time)
        day_num = to_day_num(date_time)
        @days[day_num]
    end
    
    
    
    # returns a WorkTime object for the given DateTime object
    #
    def to_work_time(date_time)
        mins = date_time.strftime('%M').to_i
        hours = date_time.strftime('%H').to_i
        WorkTime.new(hours, mins)
    end
    
    # returns a date_time object with the time element modified to be the start_time of that day
    #
    def start_of_working_day(date_time)
        day_num = to_day_num(date_time)
        start_time = @days[day_num].start_time
        return to_modified_date_time(date_time, start_time)
    end
    
    
    # returns a DateTime object comprising the given DateTime object set to the value of the WorkTime object
    # 
    # Parameters:
    # * dt:  A DateTime object for the date which is to be returned
    # * wt:  A WorkTime object
    #
    # Returns: A DateTime object comprising the date of the dt parameter, and the time of the wt parameter
    def to_modified_date_time(dt, wt)
        DateTime.new(dt.year, dt.month, dt.day, wt.hh, wt.mm, 0)
    end
        
    
    
end
    
    
    
    
    
    
    
    
