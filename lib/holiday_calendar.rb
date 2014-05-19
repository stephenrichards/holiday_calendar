require_relative 'public_holiday_specification'
require_relative 'public_holiday'
require_relative 'religious_festival'
require_relative 'work_time_schedule'
require_relative 'holiday_calendar_version'
require_relative 'work_day'
require 'yaml'

# This class generates the public holiday date data from
# PublicHolidaySpecifications.  The class can be instantiated in one
# of three ways:
#
# * HolidayCalendar.load(:territory)
# * HolidayCalendar.load_file(yaml_file)
# * HolidayCalendar.create(:territory, [weekends], [public_holidays])

class HolidayCalendar
  attr_accessor   :territory, :weekend, :public_holiday_specifications

  @@keys_for_std_config   = [:territory]
  @@keys_for_yaml         = [:filename]
  @@keys_for_array        = [:territory, :weekend, :specs]
  @@valid_day_names       = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']

  # Instantiates a HolidayCalendar object with empty values
  def initialize
    @territory                      = nil
    @weekend                        = nil
    @public_holiday_specifications  = nil
    @generated_years                = Array.new
    @public_holiday_collection      = Array.new
    @public_holiday_hash            = Hash.new
  end

  # returns version number of installed gem
  def self.version
    HOLIDAY_CALENDAR_VERSION
  end

  # Instantiates a HolidayCalendar object from the standard
  # configuration file for the specified territory
  def self.load(territory)
    cal = HolidayCalendar.new
    self.instantiate_from_std_config(cal, territory)
    cal
  end

  # Instantiates a HolidayCalendar object from an array of
  # PublicHolidaySpecifications
  #

  # params
  # * territory:          territory name as a symbol
  # * weekend:            an array of days which are to be conisidered weekends.
  #                       Days can be specified as day numbers (Sunday = 0, Saturday = 6),
  #                       or day names as symbols in lower case.
  # * public_holidays:    an array of PublicHolidaySpecification objects
  def self.create(territory, weekend, public_holidays)
    cal = HolidayCalendar.new
    instantiate_from_array(cal, territory, weekend, public_holidays)
    cal
  end

  # Instantiates a HolidayCalendar object from a yaml file containing
  # the definition of holiday specifications.
  def self.load_file(filename)
    cal = self.new
    self.instantiate_from_yaml(cal, filename)
    cal
  end


  # Adds a new PublicHolidaySpecification or Array of
  # PublicHollidaySpecifications to the Holiday Calendar
  #
  # params
  # * phs: must be a single PublicHolidaySpecification object or an
  #   array of PublicHolidaySpecification objects to be added to the
  #   calendar.
  def <<(phs)
    if phs.is_a? PublicHolidaySpecification
      phs_array = [phs]
    else
      phs_array = phs
    end

    if !all_occurrances_of(PublicHolidaySpecification, phs_array)
      raise ArgumentError.new('you must pass a PublicHolidaySpecification or an array of PublicHolidaySpecification objects to << method of HolidayCalendar')
    end

    @public_holiday_specifications += phs_array
    @generated_years.clear
    @public_holiday_collection.clear
  end

  # Deletes a public holiday by names from the holiday calendar.
  #
  # params
  # * public_holiday_name: a string containing the name of the public
  #                        holiday to be deleted
  #
  # returns
  # * true if a public holiday with that name existed in the calendar and was deleted
  # * false if no public holiday with that name was found in the calendar
  #
  def delete(public_holiday_name)
    holiday_found = false
    index = 0
    @public_holiday_specifications.each do |phs|
      if phs.name == public_holiday_name
        holiday_found = true
        break
      end
      index += 1
    end
    @public_holiday_specifications.delete_at(index)
    @generated_years.clear
    @public_holiday_collection.clear
    holiday_found
  end

  # Returns the count of public holidays
  #
  def size
    @public_holiday_specifications.size
  end

  # Returns true if the specified date is a weekend
  #
  def weekend?(date)
    date = to_date(date)
    populate_public_holiday_collection_for_year(date.year)
    @weekend.include?(date.wday)
  end

  # returns true if the specified day number is a weekend
  def weekend_day_number?(day_number)
    @weekend.include?(day_number)
  end

  # Returns true if the specified date is a public holiday
  #
  def public_holiday?(date)
    date = to_date(date)
    return false if weekend?(date) # weekend are never public holidays
    populate_public_holiday_collection_for_year(date.year)

    return true if @public_holiday_hash.has_key?(date)
    return false
  end

  # Returns true if the specified date is neither a weekend nor a
  # public holiday
  #
  def working_day?(date, repopulate = true)
    date = to_date(date)
    if repopulate
      populate_public_holiday_collection_for_year(date.year)
    end
    !weekend?(date) && !public_holiday?(date)
  end

  # Returns the count of the number of working days between two dates
  # (does not count the start date as 1 day).
  #
  def count_working_days_between(start_date, end_date)
    start_date = to_date(start_date)
    end_date = to_date(end_date)
    populate_public_holiday_collection_for_year(start_date.year)
    populate_public_holiday_collection_for_year(end_date.year)
    if start_date >= end_date
      raise ArgumentError.new("start_date passed to HolidayCalendar.count_days_between() is not before end_date")
    end

    working_day_count = 0
    date = start_date
    while date < end_date
      date += 1
      working_day_count += 1 if  working_day?(date)
    end
    working_day_count
  end

  # Returns a date a number of working days after a specified date
  #
  # params
  # * start_date : the date at which to start counting
  # * num_working_days : the number of working days to count
  #
  def working_days_after(start_date, num_working_days)
    start_date = to_date(start_date)
    populate_public_holiday_collection_for_year(start_date.year)
    working_days_offset(start_date, num_working_days, :forward)
  end



  # Returns a date a number of working days before a specified date
  #
  # params
  # * start_date : the date at which to start counting
  # * num_working_days : the number of working days to count
  #
  def working_days_before(start_date, num_working_days)
    start_date = to_date(start_date)
    populate_public_holiday_collection_for_year(start_date.year)
    working_days_offset(start_date, num_working_days, :backward)
  end


  # Returns an array of string descriptions of each of the
  # PublicHolidaySpecifications in the calendar
  #
  def list
    specs = Array.new
    @public_holiday_specifications.each { |phs| specs << phs.to_s }
    specs
  end


  # Returns an array of strings giving the date and the name of the
  # holiday for each holiday in the year
  #
  def list_for_year(year)
    populate_public_holiday_collection_for_year(year)
    holiday_dates = Array.new
    @public_holiday_collection.each do |ph|
      holiday_dates << ph.to_s if ph.year == year
    end
    holiday_dates
  end

  # Returns the name of the holiday for a particular date, or nil if
  # the date is not a holiday
  #
  # params
  # * date: the date for which the holiday name is to be returned
  # * date_adjusted_text: true, if the phrase 'carried forward from'
  #                       or 'brought forward from' is to be included
  #                       in cases where the date of the holiday was
  #                       adjusted because it fell on a weekend (or to
  #                       be more precise, on a day specified in the
  #                       take_before or take_after options of the
  #                       PublicHolidaySpecification)
  #
  def holiday_name(date, date_adjusted_text = true)
    date = to_date(date)
    populate_public_holiday_collection_for_year(date.year)
    ph = @public_holiday_hash[date]
    if ph.nil?
      return nil
    else
      return ph.name(date_adjusted_text)
    end
  end

  private

  # converts DateTime objects to Date object
  def to_date(dt)
    Date.new(dt.year, dt.month, dt.day)
  end

  # returns true if array contains only instances of klass
  def all_occurrances_of(klass, array)
    array.each do |instance|
      if !instance.instance_of?(klass)
        return false
      end
    end
    return true
  end

  # read all yaml files in the config directory looking for one with a
  # territory of the specified name, and load it
  def self.instantiate_from_std_config(cal, territory)
    raise ArgumentError.new('No territory specified for HolidayCalendar.new in std_config mode') if territory.nil?

    territory = territory.to_s
    yaml_files = Dir[File.dirname(__FILE__) + '/../config/*.yaml']
    territory_found = false
    yaml_files.each do |yf|
      begin
        yaml_spec = YAML.load_file(yf)
        next if yaml_spec['territory'] != territory
        territory_found = true
        instantiate_from_yaml(cal, yf)
      rescue
        puts "ERROR while loading #{yf}"
        raise
      end
    end

    unless territory_found
      raise "Unable to file standard config file for territory #{territory}"
    end
  end

  def self.instantiate_from_yaml(cal, filename)
    if !File.exist?(filename)
      raise ArgumentError.new("The filename specified in HolidayCalender.new cannot be found: #{filename}")
    end

    yaml_file_contents = YAML.load_file(filename)
    validate_yaml_file_contents(cal, filename, yaml_file_contents)
  end

  def self.validate_yaml_file_contents(cal, filename, yaml_file_contents)
    validate_and_populate_territory(cal, filename, yaml_file_contents)
    validate_and_populate_weekend(cal, filename, yaml_file_contents)
    validate_and_populate_public_holidays(cal, filename, yaml_file_contents)
  end

  def self.validate_and_populate_territory(cal, filename, yaml_file_contents)
    if !yaml_file_contents.has_key? 'territory'
      raise ArgumentError.new("YAML file #{filename} does not have a 'territory' setting")
    end
    cal.territory = yaml_file_contents['territory'].to_sym
  end

  def self.validate_and_populate_weekend(cal, filename, yaml_file_contents)
    raise ArgumentError.new("YAML file #{filename} does not have a 'weekend' setting") if !yaml_file_contents.has_key? 'weekend'
    klass = yaml_file_contents['weekend'].class
    raise ArgumentError.new("Invalid YAML file element 'weekend' - must be an Array, is #{klass}") if klass != Array

    weekend_array = Array.new

    yaml_file_contents['weekend'].each do |day|
      day_num = @@valid_day_names.index(day.downcase)
      raise ArgumentError.new("Invalid day specified as weekend: #{day}") if !day_num
      weekend_array << day_num
    end
    cal.weekend = weekend_array
  end

  def self.validate_and_populate_public_holidays(cal, filename, yaml_file_contents)
    raise ArgumentError.new("YAML file #{filename} does not have a 'public_holidays' setting") if !yaml_file_contents.has_key? 'public_holidays'
    klass = yaml_file_contents['public_holidays'].class
    raise ArgumentError.new("Invalid YAML file element 'public_holidays' - must be an Hash, is #{klass}") if klass != Hash

    phs_array = Array.new
    yaml_file_contents['public_holidays'].each do |name, yaml_spec|
      phs = PublicHolidaySpecification.instantiate_from_yaml_definition(filename, name, yaml_spec)
      phs_array<< phs
    end
    cal.public_holiday_specifications = phs_array
  end

  def self.instantiate_from_array(cal, territory, weekend, public_holiday_specifications)
    validate_territory(territory)
    valid_weekend = validate_weekend(weekend)
    validate_public_holiday_specifications(public_holiday_specifications)

    cal.territory = territory
    cal.weekend = valid_weekend
    cal.public_holiday_specifications = public_holiday_specifications
  end

  def self.validate_territory(territory)
    raise ArgumentError.new('territory must be specified as symbol in HolidayCalendar.create') if !territory.is_a? Symbol
  end

  def self.validate_weekend(weekend)
    raise ArgumentError.new('weekend must be specified as an Array in HolidayCalendar.create') if !weekend.is_a? Array
    valid_weekend = Array.new
    weekend.each do |day|
      valid_weekend <<  self.normalise_day(day)
    end
    valid_weekend
  end

  def self.validate_public_holiday_specifications(public_holiday_specifications)
    raise ArgumentError.new('public_holidays must be specified as an Array in HolidayCalendar.create') if !public_holiday_specifications.is_a? Array
    public_holiday_specifications.each do |phs|
      raise ArgumentError.new('public holidays must be an array of PublicHolidaySpecification objects in HolidayCalendar.create') if !phs.instance_of?(PublicHolidaySpecification)
    end
  end

  def self.normalise_day(day)
    if day.is_a? Fixnum
      if day >= 0 && day < 7
        return day
      end
    end
    if day.is_a? String
      day.downcase!
      if @@valid_day_names.include?(day)
        return @@valid_day_names.index(day)
      end
    end
    raise ArgumentError.new('Invalid weekend array passsed to HolidayCalendar.create: each day must be day number in range 0-6 or day name')
  end



  #  for the specified year (and a year either side so as to cater for
  #  holidays that get taken before in the last day of the previous
  #  year, or taken after in the first day of the next year), iterates
  #  through the collection of public holiday specifications and
  #  generates a PublicHoliday object for each one for the specified
  #  year and adds it to the collection of public holidays.
  def populate_public_holiday_collection_for_year(year)
    return if @generated_years.include?(year)                   # don't generate if we've already done it
    @public_holiday_specifications.each do |phs|
      next if !phs.applies_to_year?(year)
      @public_holiday_collection << PublicHoliday.new(phs, year)
    end
    @generated_years << year                                    # add to the list of years we've generated
    @public_holiday_collection.sort!
    populate_public_holiday_hash
    adjust_carry_forwards
    populate_holidays_brought_forward_from_next_year(year + 1)
  end


  # handles the edge case where early holidays in the following year
  # are brought forward to this year.  this method is called with the
  # following year as a parameter
  def populate_holidays_brought_forward_from_next_year(year)
    return if @generated_years.include?(year)               # no need to do anything if the holidays have already been generated for this year
    @public_holiday_specifications.each do |phs|
      next if !phs.applies_to_year?(year)
      ph = PublicHoliday.new(phs, year)
      if ph.must_be_taken_before?
        new_date = last_working_day_before(ph.date)
        if new_date.year < ph.date.year
          ph.adjust_date(new_date)
          @public_holiday_hash[new_date] = ph
        end
      end
    end
  end

  # refreshes the public_holiday_hash based on the contents of the
  # public_holiday_collection
  def populate_public_holiday_hash
    @public_holiday_hash = Hash.new
    @public_holiday_collection.each do |ph|
      @public_holiday_hash[ph.date] = ph
    end
  end

  # iterates through the public_holiday_collection, and where a public
  # holiday falls on a day which is in the take_before or take_after
  # array, then adjusts the date accordingly
  def adjust_carry_forwards
    @public_holiday_collection.each do |ph|
      if ph.must_be_taken_after?
        new_date = next_working_day_after(ph.date)
        @public_holiday_hash.delete(ph.date)
        ph.adjust_date(new_date)
        @public_holiday_hash[new_date] = ph
      elsif ph.must_be_taken_before?
        new_date = last_working_day_before(ph.date)
        @public_holiday_hash.delete(ph.date)
        ph.adjust_date(new_date)
        @public_holiday_hash[new_date] = ph
      end

    end
  end

  def next_working_day_after(date)
    date +=1
    while !working_day?(date) do
      date += 1
    end
    date
  end

  def last_working_day_before(date)
    date -= 1
    while !working_day?(date) do
      date -= 1
    end
    date
  end

  def working_days_offset(start_date, num_working_days, direction)
    date = start_date
    while num_working_days > 0 do
      if direction == :forward
        date += 1
      else
        date -= 1
      end
      num_working_days -= 1 if working_day?(date)
    end
    date
  end
end
