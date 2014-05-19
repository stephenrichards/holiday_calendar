
# Encapsulates a date which is a public holiday for a particular year derived from a 
# PublicHolidaySpecification and a year

class PublicHoliday
    
  include Comparable
  
  attr_reader     :year
  attr_accessor   :date, :date_adjusted_text
  attr_writer     :name

  
  # Instantiates a PublicHoliday object
  # 
  # params
  # * public_holiday_specification: a PublicHolidaySpecification object
  # * year: a year number
  # 
  
  def initialize(public_holiday_specification, year)
      
      @year = year
      @holiday = false
      @date = nil
      @name = nil
      @take_before = Array.new
      @take_after = Array.new
      @date_adjusted = false
      @date_adjusted_text = nil
      
      if public_holiday_specification.applies_to_year?(year)
          @holiday = true
          setup_public_holiday(public_holiday_specification, @year)
      end
  end
  
  
  def <=>(other)
      self.date <=> other.date
  end
  
  
  # returns the date and name of the holiday, and optionally, the date adjustedtext if any.
  def to_s(date_adjusted_text = true)
      description = "#{@date.strftime("%a %d %b %Y")} : #{self.name}"
      # if date_adjusted_text  && @date_adjusted
      #     description += " (#{@date_adjusted_text})"
      # end
      description
  end
  
  
  def name(date_adjusted_text = true)
      description = @name
      if date_adjusted_text  && @date_adjusted
          description += " (#{@date_adjusted_text})"
      end
      description        
  end
  
  
  
  # returns true if the day number of the holiday date is in the taken_before array
  def must_be_taken_before?
      return true if @take_before.include? @date.wday
      return false
  end
  
  
  
  def must_be_taken_after?
      return true if @take_after.include? @date.wday
      return false
  end


  def holiday?
      @holiday
  end



  def adjust_date(new_date)
      @date_adjusted = true
      if new_date > @date
          direction = 'carried'
      else
          direction  = 'brought'
      end
      @date_adjusted_text = "#{direction} forward from #{@date.strftime('%a %d %b %Y')}"
      @date = new_date
  end



  private
  def setup_public_holiday(phs, year)
     @name = phs.name
     if phs.uses_class_method?
         @date = phs.klass.send(phs.method_name, year)
     elsif phs.day.is_a? Fixnum
         @date = Date.new(year, phs.month, phs.day)
     else
         @date = generate_date_from_expression(phs, year)
     end
     
     @take_before = phs.take_before
     @take_after = phs.take_after
  end
         

  # generates an actual date for @year from the PublicHolidaySpecification when the specification is written as an expression
  def generate_date_from_expression(phs, year)
    if phs.day.class != ModifiedWeekday
      raise RuntimeError.new("Error - expecting PublicHolidaySpecification.day to be a ModifiedWeekday: is a #{phs.day.class}")
    end
    month = phs.month
    wday = phs.day.wday
    occurrance = phs.day.weekday_occurrance

     
    if phs.day.modifier == :last
      date = get_last_wday_in_month(year, month, wday)
    else
      date = get_nth_day_in_month(year, month, wday, occurrance)
    end
    date
  end



  # returns the date of the nth monday, tuesday, etc. in a month for a particular year
  #
  # params
  # * year : the year for which the date is to be generated
  # * month : the month number (1-12) for which the date is to be generated
  # * wday : the wday number (Sunday = 0, Saturday = 6) for which the date is to be generated
  # * n : the n in nth monday (range 1 - 4 inclusive)
  #
  def get_nth_day_in_month(year, month, wday, n)
    first_day_of_month = Date.new(year, month, 1)
    wday_of_first_day = first_day_of_month.wday
    day_number = wday - wday_of_first_day + 1
    day_number += 7 if day_number < 1

    # now add on 7 days for each 'n'
    n -= 1
    day_number += (n * 7)

    Date.new(year, month, day_number)
  end
         





  # determines the date of the last specified weekday in a month
  def get_last_wday_in_month(year, month, wday)
    last_day_in_month = Date.new(year, month, -1)
    wday_of_last_day = last_day_in_month.wday
    wday_of_last_day += 7 if wday_of_last_day < wday
    difference = wday_of_last_day - wday
    date = last_day_in_month - difference
    date
  end

    
end
        
        
        