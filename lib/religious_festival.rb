require 'date'

class ReligiousFestival
  #Get the date for easter sunday given the year.
  def self.easter(year)

    golden_number = (year % 19) + 1
    year_of_calender_reform = 1752

    if year <= year_of_calender_reform then
      # Julian calendar
      dominical_number = (year + (year / 4) + 5) % 7
      paschal_full_moon = (3 - (11 * golden_number) - 7) % 30
    else
      # Gregorian calendar
      dominical_number = (year + (year / 4) - (year / 100) + (year / 400)) % 7
      solar_correction = (year - 1600) / 100 - (year - 1600) / 400
      lunar_correction = (((year - 1400) / 100) * 8) / 25
      paschal_full_moon = (3 - 11 * golden_number + solar_correction - lunar_correction) % 30
    end

    dominical_number += 7 until dominical_number > 0
    paschal_full_moon += 30 until paschal_full_moon > 0
    paschal_full_moon -= 1 if paschal_full_moon == 29 or (paschal_full_moon == 28 and golden_number > 11)
    difference = (4 - paschal_full_moon - dominical_number) % 7
    difference += 7 if difference < 0
    easter_day = paschal_full_moon + difference + 1

    if easter_day < 11 then
      # Easter occurs in March.
      return Date.new(year, 3, easter_day + 21)
    else
      # Easter occurs in April.
      return Date.new(year, 4, easter_day - 10)
    end
  end

  # Determine the date of Good Friday for a given year.
  #
  def self.good_friday(some_year)
    easter(some_year) - 2
  end

  # Determine the date of Palm Sunday for a given year.
  #
  def self.palm_sunday(some_year)
    easter(some_year) - 7
  end

  # Determines the date of Ash Wednesday for a given year.
  #
  def self.ash_wednesday(some_year)
    easter(some_year) - 46
  end

  # Determines the date of Ascension Day for a given year.
  #
  def self.ascension_day(some_year)
    easter(some_year) + 39
  end

  # Determines the date of Pentecost for a given year.
  #
  def self.pentecost(some_year)
    easter(some_year) + 49
  end

  def self.whit_sunday(some_year)
    easter(some_year) + 49
  end

  def self.whit_monday(some_year)
    easter(some_year) + 50
  end

  # determine the date of Easter Monday for a given year
  #
  def self.easter_monday(some_year)
    easter(some_year) + 1
  end
end
