require File.dirname(__FILE__) + '/public_holiday'
require File.dirname(__FILE__) + '/religious_festival'
require 'yaml'



# This class generates the public holiday date data from PublicHolidaySpecifications.  The class can be instantiated in one of three
# ways:
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
    
    
    # Instantiates a HolidayCalendar object from the standard configuration file for the specified territory
    def self.load(territory)
        cal = HolidayCalendar.new
        self.instantiate_from_std_config(cal, territory)
        cal
    end    
    

    # Instantiates a HolidayCalendar object from an array of PublicHolidaySpecifications
    #
    # params
    # * territory:          territory name as a symbol
    # * weekend:            an array of days which are to be conisidered weekends.  Days can be specified as day numbers (Sunday = 0, Saturday = 6), or day names as symbols in lower case.
    # * public_holidays:    an array of PublicHolidaySpecification objects  
    def self.create(territory, weekend, public_holidays)
        cal = HolidayCalendar.new
        instantiate_from_array(cal, territory, weekend, public_holidays)
        cal
    end
    
    
    # adds a new PublicHolidaySpecification or Array of PublicHollidaySpecifications to the Holiday Calendar  
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
             
        
    # deletes a public holiday by names from the holiday calendar.
    # 
    # params
    # * public_holiday_name: a string containing the name of the public holiday to be deleted
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
    
    
    
   
    # Instantiates a HolidayCalendar object from a yaml file containing the definition of holiday specifications.
    def self.load_file(filename)
        cal = self.new
        self.instantiate_from_yaml(cal, filename)
        cal
    end
        
    # returns the count of public holidays 
    def size
        @public_holiday_specifications.size
    end


    # returns true if the specified date is a weekend
    def weekend?(date)
        populate_public_holiday_collection_for_year(date.year)
        @weekend.include?(date.wday)
    end
    
    
    # returns true if the specified date is a public holiday

    def public_holiday?(date)
        return false if weekend?(date)                  # weekend are never public holidays
        populate_public_holiday_collection_for_year(date.year)
        
        return true if @public_holiday_hash.has_key?(date)
        return false
    end

    
    
    
        
    # returns true if the specified date is neither a weekend nor a public holiday
    def working_day?(date)
        populate_public_holiday_collection_for_year(date.year)
        !weekend?(date) && !public_holiday?(date)
    end
        
        
    # returns the count of the number of working days between two dates (does not count the start date as 1 day). 
    def count_working_days_between(start_date, end_date)
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
    
    
    
    
    # returns a date a number of working days after a specified date
    #
    # params
    # * start_date : the date at which to start counting
    # * num_working_days : the number of working days to count
    #
    def working_days_after(start_date, num_working_days)
        populate_public_holiday_collection_for_year(start_date.year)
        working_days_offset(start_date, num_working_days, :forward)
    end
    
    
    
    # returns a date a number of working days before a specified date
    #
    # params
    # * start_date : the date at which to start counting
    # * num_working_days : the number of working days to count
    #
    def working_days_before(start_date, num_working_days)
        populate_public_holiday_collection_for_year(start_date.year)
        working_days_offset(start_date, num_working_days, :backward)
    end    
    
    
    def list_for_year(year)
        populate_public_holiday_collection_for_year(year)
        @public_holiday_collection.each do |ph|
            puts ph
        end
    end
    
    
    def holiday_name(date, carry_forward_text = true)
        populate_public_holiday_collection_for_year(date.year)
        ph = @public_holiday_hash[date]
        if ph.nil?
            return nil
        else
            return ph.name(carry_forward_text)
        end
    end
    
    
    
    private
    
    # returns true if array contains only instances of klass
    def all_occurrances_of(klass, array)
        array.each do |instance|
            if !instance.instance_of?(klass)
                return false
            end
        end
        return true
    end
    
    
    
    # read all yaml files in the config directory looking for one with a territory of the specified name, 
    # and load it
    def self.instantiate_from_std_config(cal, territory)
        raise ArgumentError.new('No territory specified for HolidayCalendar.new in std_config mode') if territory.nil?
        
        territory = territory.to_s
        yaml_files = Dir[File.dirname(__FILE__) + '/../config/*.yaml']
        yaml_files.each do |yf|
            begin
                yaml_spec = YAML.load_file(yf)
                next if yaml_spec['territory'] != territory
                instantiate_from_yaml(cal, yf)
            rescue => err
                puts "ERROR while loading #{yf}"
                raise
            end    
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
    
    
    
    
    # def validate_keys_for_array_mode(options)
    #     valid_keys = [:mode, :territory, :weekend, :specs]
    #     options.keys.each do |key|
    #         if !valid_keys.include?(key)
    #             raise ArgumentError.new("Invalid key passed to HolidayCalendar.new in :array mode: #{key}")
    #         end
    #         valid_keys.delete(key)
    #     end
    #     if valid_keys.size != 0
    #         raise ArgumentError.new("The following mandatory keys were not passed to HolidayCalendar.new in :array mode: #{valid_keys.join(', ')}")
    #     end
    # end
    
    
    
    
    
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
            if weekend?(ph.date)  && ph.carry_forward?
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
        