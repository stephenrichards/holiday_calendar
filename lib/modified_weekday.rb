# This class encapsulates all the information needed to describe something like 
# first monday, second thursday or last wednesday of a particular month.

class ModifiedWeekday
    
    
    @@valid_weekdays    = [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]
    @@valid_modifiers   = [:last, :first, :second, :third, :fourth]
    
    
    attr_reader :weekday_name, :modifier, :wday, :weekday_occurrance, :expression, :is_last
    
    # Instantiate a ModifiedWeekday object from either an expression such as :first_monday, or a date object
    #
    # params
    # * param : param can either be a valid expression or a date object.
    #   * valid expressions are :xxxx_yyyyyy where xxxx is :first, :second, :third, :fourth, :last and yyyy is monday, tuesday, etc.
    # 
    def initialize(param)
        @weekday_name  = nil
        @modifier = nil
        @wday = nil
        @weekday_occurrance = nil    # 0 = last, 1 = first, 2 = second, etc.
        @is_last = false
        
        
        if param.is_a? Symbol
            @expression = param
            string_expr = @expression.to_s
            string_modifier, string_weekday = string_expr.split('_')
            @weekday_name = string_weekday.to_sym
            @modifier = string_modifier.to_sym
            validate_weekday
            validate_modifier
            @is_last = true if @modifier == :last
        elsif param.is_a? Date
            get_modifiers_from_date(param)
        else
            raise ArgumentError.new("Invalid Type passed to ModifiedWeekday.new: #{param.class}")
        end
    
    end
    
    
    def to_s
        @modifier.to_s + "_" + @weekday_name.to_s
    end
    
    
    
    def sort_value
        sort_val = @weekday_occurrance * 10
        sort_val = 50 if sort_val == 0
        sort_val += @wday
    end
    


    # Compare two ModifiedWeekday objects.  Objects are equal if the expression is the same, or the days are the same and the modifier is :last and / or is_last is true.
    def ==(other)
        return true if other.expression == self.expression
        
        if other.weekday_name == self.weekday_name
            if other.is_last == true || other.modifier == :last
                if self.is_last == true || self.modifier == :last
                    return true
                end
            end
        end
        return false
    end



    private
    
    def get_modifiers_from_date(date)
       @weekday_name = @@valid_weekdays[date.wday]
       @wday = date.wday
       @weekday_occurrance = get_weekday_occurrance(date)
       determine_whether_last(date)
       @modifier = make_modifier
       @expression = (@modifier.to_s + '_' + @weekday_name.to_s).to_sym
       
    end
    
    
    
    def get_weekday_occurrance(date)
        num_weeks = date.mday / 7
        remainder = date.mday % 7
        if remainder > 0
            occurrance = num_weeks + 1
        else
            occurrance= num_weeks
        end
        occurrance
    end
    
    
    def determine_whether_last(date)
       days_in_month = Date.new(date.year, date.month, -1).day
       days_left = days_in_month - date.day
       if days_left < 7
           @is_last = true
       end
    end
    
    
    
    def make_modifier
        modifier = @@valid_modifiers[@weekday_occurrance]
        if !modifier && @is_last
            modifier = :last
        end
        modifier
    end
    
    
    
    def validate_weekday
        if !@@valid_weekdays.include?(@weekday_name)
            raise ArgumentError.new("Invalid Weekday component passed to ModifiedWeekday.new: #{@expression}")
        end
        @wday = @@valid_weekdays.index(@weekday_name)
    end
    
    
    def validate_modifier
        if !@@valid_modifiers.include?(@modifier)
            raise ArgumentError.new("Invalid weekday modifier passed to ModifiedWeekday.new: #{@expression}")
        end
        @weekday_occurrance = @@valid_modifiers.index(@modifier)
    end
end