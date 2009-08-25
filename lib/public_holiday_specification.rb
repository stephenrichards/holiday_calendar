require File.dirname(__FILE__) + '/modified_weekday'

# Encapsulates the specification for a public Holiday, from which Named Public Holidays for any year can be generated.

class PublicHolidaySpecification
    include Enumerable
    
    attr_reader     :name, :day, :month, :uses_class_method, :klass, :method_name
    
    
    @@month_names = {'January' => 1, 'February' => 2, 'March' => 3, 'April'=> 4,
                     'May' => 5, 'June' => 6, 'July' => 7, 'August' => 8,
                     'September' => 9, 'October' => 10, 'November' => 11, 'December' => 12}
    
    # Instantiates a PublicHolidaySpecification object.
    #
    # params:  key-value pairs as follows:
    # * name:           Name given to this public holiday.  Mandatory.
    # * years:          Either :all, a single year, or a range. Mandatory.
    # * month:          Either an English month name, or month number in range 1-12.  Mandatory.
    # * day:            Either a number, or a phrase like :first_monday, :third_tuesday, :last_thursday.  Mandatory.
    # * carry_forward:  Either true or false.  If true, and the holiday falls on a weekend, the holiday is carried over
    #   to the next working day.  Optional; if not supplied, false is assumed                   
    #
    # e.g.
    #                   phs = PublicHolidaySpecification.new(:name => 'Christmas', :years => :all, :month => 12, :day => 25, :carry_forward => true)
    #
    # or
    # * name:           Name given to this public holiday.  Mandatory.
    # * years:          Either :all, a single year, or a range. Mandatory
    # * class_method:   Name of a class method that takes a year and returns a date
    # 
    # e.g.
    #                   phs = PublicHolidaySpecification.new(:name => 'Good Friday', :years => :all, :class_method => 'ReligiousFestival.good_friday')
    # 
    def initialize(params)
        @name               = nil
        @years              = nil
        @month              = nil
        @day                = nil
        @uses_class_method  = false
        @klass              = nil
        @method_name        = nil
        @carry_forward      = false
        
        validate_params(params)
        # @sort_value = generate_sort_value
    end
    
    
    
    def self.instantiate_from_yaml_definition(filename, name, yaml_spec)
        raise ArgumentError.new("Invalid definition of #{name} in public_holidays section of #{filename}") if !yaml_spec.is_a? Hash
        params = Hash.new
        params[:name] = name
        yaml_spec.each do |key, value|
            key = key.to_sym if key.is_a? String
            unless key == :class_method
                value = value.to_sym if value.is_a? String
            end
            params[key] = value
        end
        phs = PublicHolidaySpecification.new(params)
        phs
    end
    
    
    
    def uses_class_method?
        @uses_class_method
    end




    # returns true if the years value for this PublicHolidaySpecification includes the specified year.
    def applies_to_year?(year)
        @years.include?(year)
    end
    
    
    # the sorting function is used in order to sort the public holiday specifications for one year into 
    # order before generating the holiday calendar, to ensure that carry over holidays in succession
    # get carried over properly  (e.g. DEc 25/26 falling on Sat / Sun get carried over to Mon / Tue)
    def <=>(other)
        self.sort_value <=> other.sort_value
    end
    
    
    # returns true if this holiday is carried forward to the next working day if it falls on a weekend
    def carry_forward?
        @carry_forward
    end
    
    
    # displays human_readable form of 
    def to_s
        str = @name + "\n"
        str += sprintf("  %014s: %s\n", 'years', @years)
        if @uses_class_method
            str += sprintf("  %14s: %s.%s\n\n", 'class_method', @klass, @method_name)
        else
            str += sprintf("  %14s: %s\n", 'month', @month)
            str += sprintf("  %14s: %s\n", 'day', @day)
            str += sprintf("  %14s: %s\n\n", 'carry_forward', @carry_forward)
        end
    end
        
    
    private
    def public_holiday_on_actual_date?(date)
        result = false
        if @years.include?(date.year)  && @month == date.month
            if @day.is_a? ModifiedWeekday
                result = true if ModifiedWeekday.new(date) == @day
            else
                result = true if @day == date.day
            end
        end
        result
    end        
    
    
    
    
    def validate_params(params)
            
        params.each do |key, value|
            case key
            when :name
                @name = value
            when :years
                @years = validate_years(value)
            when :month
                @month = validate_month(value)
            when :day
                @day = validate_day(value)
            when :carry_forward
                @carry_forward = validate_carry_forward(value)
            when :class_method
                validate_class_method(value)
            else
                raise ArgumentError.new("Invalid parameter passed to PublicHolidaySpecification.new: #{key} => #{value}")
            end
        end

        missing_params = any_mandatory_params_nil?
        if missing_params.size != 0
            raise ArgumentError.new("Mandatory parameters are missing in a call to PublicHolidaySpecification.new: #{missing_params.join(', ')}")
        end 
    end
    
    
    def validate_class_method(value)
       class_method =  value
       classname, method_name = value.split('.')
       klass = Kernel.const_get(classname)
       
       begin
           valid_method = klass.respond_to?(method_name)
       rescue NameError => err
           puts "Unknown Class passed to PublicHolidaySpecification.new as class_method parameter: #{class_method}"
           raise
       end
       
       if !valid_method
           raise NameError.new("Unknown method passed to PublicHolidaySpecification.new as class_method parameter: #{class_method}")
       end
       
       @uses_class_method = true
       @klass = klass
       @method_name = method_name
    end
    
    
    
    
    
    def validate_years(value)
        if value == :all
            @years = (0..9999)
        elsif value.class == Fixnum
            @years = (value..value)
        elsif value.class == Range
            @years = value
        else
            raise ArgumentError.new("Invalid value passed as years parameter. Must be a Range, Fixnum or :all")
        end
    end
    
    
    
    def validate_month(month)
        if month.is_a?(String)   &&   @@month_names.has_key?(month)
            @month = @@month_names[month]
        elsif month.is_a?(Fixnum)  && (1..12).include?(month)
            @month = month
        else
            raise ArgumentError.new("Invalid month passed to PublicHolidaySpecification.new: #{month}")
        end
    end
    
    
    
    def validate_day(day)
        if day.is_a?(Symbol)
            @day = ModifiedWeekday.new(day)
        elsif day.is_a?(Fixnum)  && (1..31).include?(day)
            @day = day
        else
            raise ArgumentError.new("Invalid value passed as :day parameter to PublicHolidaySpecification.new: #{day}")
        end
    end
    
    
    def validate_carry_forward(value)
        if !value.is_a?(TrueClass)  &&  !value.is_a?(FalseClass)
            raise ArgumentError.new(':carry_forward value passed to PublicHolidaySpecification.new must be true or false')
        end
        @carry_forward = value
    end
        
    
        
    def any_mandatory_params_nil?
        return_array = []
        return_array << :name if !@name
        return_array << :years if !@years
        if !@uses_class_method
            return_array << :month if !@month
            return_array << :day if !@day
        end
        return_array
    end
    
end
                
        
        
    
    
    