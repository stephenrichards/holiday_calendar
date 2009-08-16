require File.dirname(__FILE__) + '/public_holiday'



# This class generates the public holiday date data from PublicHolidaySpecifications.  The class can be instantiated in one of three
# ways:
#
# * from a standard configuration distributed with the gem
# * from a yaml file supplied by the user
# * from an array of PublicHolidaySpecification objects created by the user.
#



class HolidayCalendar
    
    attr_reader :territory, :weekends
    
    @@keys_for_std_config   = [:territory]
    @@keys_for_yaml         = [:filename]
    @@keys_for_array        = [:territory, :weekends, :specs]
    
    
   # instantiate a HolidayCalendar object
   #
   # params
   # * options: a hash of keywords in one of the following three styles
   #   * :mode => std_config, :territory => :xx
   #   * :mode => yaml, :filename => 'path/to/yaml/file'
   #   * :mode => array, :territory => :xx, :weekends => [n, n], :specs => [phs1, phs2, phs3, ...]
   #
    def initialize(options)
        @territory                      = nil
        @weekends                       = nil
        @public_holiday_specifications  = nil
        @generated_years                = Array.new
        @public_holiday_collection      = Array.new
        @public_holiday_hash            = Hash.new
        
        if !options.has_key?(:mode)
            raise ArgumentError.new("No :mode parameter passed to HolidayCalendar.new")
        end
        
        case options[:mode]
        when :std_config
            instantiate_std_from_config(options)
        when :yaml
            instantiate_from_yaml(options)
        when :array
            instantiate_from_array(options)
        else
            raise ArgumentError.new("Invalid :mode parameter passed to HolidayCalendar.new: #{options[:mode].inspect}")
        end
        
        
    end
         
    
    
    

    # returns true if the specified date is a weekend
    def weekend?(date)
        @weekends.include?(date.wday)
    end
    
    
    # returns true if the specified date is a public holiday

    def public_holiday?(date)
        return false if weekend?(date)                  # weekends are never public holidays
        populate_public_holiday_collection_for_year(date.year)
        
        return true if @public_holiday_hash.has_key?(date)
        return false
    end

    
    
    
        
    # returns true if the specified date is neither a weekend nor a public holiday
    def working_day?(date)
        !weekend?(date) && !public_holiday?(date)
    end
        
        
    # returns the count of the number of working days between two dates (does not count the start date as 1 day). 
    def count_working_days_between(start_date, end_date)
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
    
    
    
    
    # returns a date a number of working days after a specified date
    #
    # params
    # * start_date : the date at which to start counting
    # * num_working_days : the number of working days to count
    #
    def working_days_after(start_date, num_working_days)
        working_days_offset(start_date, num_working_days, :forward)
    end
    
    
    
    # returns a date a number of working days before a specified date
    #
    # params
    # * start_date : the date at which to start counting
    # * num_working_days : the number of working days to count
    #
    def working_days_before(start_date, num_working_days)
        working_days_offset(start_date, num_working_days, :backward)
    end    
    
    
    def list_for_year(year)
        populate_public_holiday_collection_for_year(year)
        @public_holiday_collection.each do |ph|
            puts ph
        end
    end
    
    
    
    private
    
    # read all yaml files in the config directory looking for one with a territory of the specified name, 
    # and load it
    def instantiate_std_from_config
        x = 5
    end
    
    
    def instantiate_from_yaml
        x = 5
    end
    
    
    
    def instantiate_from_array(options)
        validate_keys_for_array_mode(options)
        @weekends = options[:weekends]
        @public_holiday_specifications = options[:specs]
    end
    
    
    def validate_keys_for_array_mode(options)
        valid_keys = [:mode, :territory, :weekends, :specs]
        options.keys.each do |key|
            if !valid_keys.include?(key)
                raise ArgumentError.new("Invalid key passed to HolidayCalendar.new in :array mode: #{key}")
            end
            valid_keys.delete(key)
        end
        if valid_keys.size != 0
            raise ArgumentError.new("The following mandatory keys were not passed to HolidayCalendar.new in :array mode: #{valid_keys.join(', ')}")
        end
    end
    
    
    
    
    
    # 
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
    end
    

    # refreshes the public_holiday_hash based on the contents of the public_holiday_collection
    def populate_public_holiday_hash
        @public_holiday_hash = Hash.new
        @public_holiday_collection.each do |ph|
            @public_holiday_hash[ph.date] = ph
        end
    end
    
    
    # iterates through the public_holiday_collection, and where a public holiday falls on a weekend
    # and carry forward is set to true, moves it to the next available work day
    def adjust_carry_forwards
        @public_holiday_collection.each do |ph|
            if weekend?(ph.date)
                new_date = next_working_day_after(ph.date)
                @public_holiday_hash.delete(ph.date)
                ph.carry_forward_text = "carried forward from #{ph.date.strftime('%a %d %b %Y')}"
                ph.date = new_date
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





    
    
    def working_days_offset(start_date, num_working_days, direction)
        date = start_date
        while num_working_days > 0 do
            if direction == :forward
                date += 1
            else
                date -= 1
            end
            # puts "#{date} #{num_working_days}  #{working_day?(date)}"
            num_working_days -= 1 if working_day?(date)
        end
        date
    end

        
end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
        