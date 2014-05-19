# Class to hold details about Time with no notion of date
class WorkTime
  include Comparable

  attr_reader :hh, :mm, :minutes

  # Instantiates a WorkTime object from a 3 or 4 digit number representing hours and minutes
  def initialize(hh, mm)
    raise 'Hours must be in range 0-23' if (hh < 0 || hh > 23)
    raise 'Minutes must be in range 0-59' if (mm < 0 || mm > 59)
    @hh      = hh
    @mm      = mm
    @minutes = (hh * 60) + mm
  end

  def -(other)
    raise 'Time to be subtracted must be less than this time' if other.minutes > @minutes
    @minutes - other.minutes
  end

  def to_s
    "#{@hh}:#{@mm}"
  end

  def <=>(other)
    @minutes <=> other.minutes
  end
end
