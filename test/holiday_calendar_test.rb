require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../lib/holiday_calendar'
require File.dirname(__FILE__) + '/../lib/public_holiday_specification'



class HolidayCalendarTest < Test::Unit::TestCase
    
  
    ########### setup methods
    
    def setup
        # create a working day schema with three public holidays, and weekends on Saturday, Sunday
        xmas    = PublicHolidaySpecification.new(:name => 'Christmas Day', :years => :all, :month => 12, :day => 25, :carry_forward => true)
        box     = PublicHolidaySpecification.new(:name => 'Boxing Day', :years => :all, :month => 12, :day => 26, :carry_forward => true)
        mayday  = PublicHolidaySpecification.new(:name => 'May Day', :years => :all, :month => 5, :day => :first_monday, :carry_forward => true)
        tg      = PublicHolidaySpecification.new(:name => 'Thanksgiving Day', :years => :all, :month => 11, :day => :last_thursday)
        summer  = PublicHolidaySpecification.new(:name => 'Summer Bank Holiday', :years => :all, :month => 8, :day => :last_monday)
        spring  = PublicHolidaySpecification.new(:name => 'Spring Bank Holiday', :years => :all, :month => 5, :day => :last_monday)
        newyear = PublicHolidaySpecification.new(:name => "New Year's Day", :years => :all, :month => 1, :day => 1)
        olympic = PublicHolidaySpecification.new(:name => 'Olympics Day', :years => 2012, :month => 8, :day => 12)
        
        @cal = HolidayCalendar.new(:mode => :array, 
                                   :territory => :uk, 
                                   :weekend => [0,6], 
                                   :specs => [xmas, mayday, tg, box, newyear, spring, olympic, summer])
                                   
        @yaml_filename = File.dirname(__FILE__) + '/test.yaml'
    end
    
    def setup_yaml_contents
        @yaml_contents = Hash.new
        @yaml_contents['territory'] = 'uk'
        @yaml_contents['weekend'] = ['saturday', 'sunday']
        public_holidays = Hash.new
        public_holidays["New Year's Day"]           = {"month"=>1, "years"=>"all", "day"=>1}
        public_holidays["Mayday"]                   = {"month"=>5, "years"=>"all", "day"=>"first_monday"}
        public_holidays["Good Friday"]              = {"class_method"=>"ReligiousFestival.good_friday", "years"=>"all"}
        
        @yaml_contents['public_holidays'] = public_holidays
    end
        
    
    def save_yaml_contents
        File.open(@yaml_filename, 'w') { |f|  YAML.dump(@yaml_contents, f) }
    end
    
    
    
    ############# tests 
    
    def test_exception_raised_if_no_filename_parameter_passed_to_new_in_yaml_mode
        err = assert_raise ArgumentError do
            cal = HolidayCalendar.new(:mode => :yaml, :xxx => 'yyy')
        end
        assert_equal 'The following mandatory keys were not passed to HolidayCalendar.new in :yaml mode: :filename', err.message
    end   
    
    
    def test_exception_thrown_when_no_territory_setting_supplied_in_yaml_file
        # given a yaml file with no territory section
        setup_yaml_contents
        @yaml_contents.delete('territory')
        save_yaml_contents
        
        # when I try to instantiate a HolidayCalendar from the file
        # I should get an exception
        err = assert_raise ArgumentError do
            cal = HolidayCalendar.new(:mode => :yaml, :filename => @yaml_filename)
        end
        assert_equal "YAML file #{@yaml_filename} does not have a 'territory' setting", err.message
    end
        
    
    def test_exception_thrown_when_no_weekend_setting_supplied_in_yaml_file
        # given a yaml file with no weekend section
        setup_yaml_contents
        @yaml_contents.delete('weekend')
        save_yaml_contents
        
        # when I try to instantiate a HolidayCalendar from the file
        # I should get an exception
        err = assert_raise ArgumentError do
            cal = HolidayCalendar.new(:mode => :yaml, :filename => @yaml_filename)
        end
        assert_equal "YAML file #{@yaml_filename} does not have a 'weekend' setting", err.message
    end    
    
    def test_exception_thrown_when_no_weekend_setting_in_yaml_file_is_not_an_array
        # given a yaml file with no weekend section
        setup_yaml_contents
        @yaml_contents['weekend'] = "saturday, sunday"
        save_yaml_contents
        
        # when I try to instantiate a HolidayCalendar from the file
        # I should get an exception
        err = assert_raise ArgumentError do
            cal = HolidayCalendar.new(:mode => :yaml, :filename => @yaml_filename)
        end
        assert_equal "Invalid YAML file element 'weekend' - must be an Array, is String", err.message
    end    
    
    
    def test_exception_thrown_when_invalid_day_name_given_as_weekend_in_yaml_file
        # given a yaml file with an invalid weekend section
        setup_yaml_contents
        @yaml_contents['weekend'] = ['subbota', 'voskresseniye']
        save_yaml_contents

        # when I try to instantiate a HolidayCalendar from the file
        # I should get an exception
        err = assert_raise ArgumentError do
            cal = HolidayCalendar.new(:mode => :yaml, :filename => @yaml_filename)
        end
        assert_equal "Invalid day specified as weekend: subbota", err.message
    end        
    
    
    def test_weekend_day_names_are_translated_into_correct_day_numbers
        # given a yaml file with no weekend section
        setup_yaml_contents
        save_yaml_contents

        # when I instantiate a HolidayCalendar from a yaml file
        cal = HolidayCalendar.new(:mode => :yaml, :filename => @yaml_filename)

        # the weekend should be setup correctly
        assert_equal [6,0],  cal.weekend
    end    
    
    
    def test_exception_thrown_when_no_public_holiday_setting_supplied_in_yaml_file
        # given a yaml file with no weekend section
        setup_yaml_contents
        @yaml_contents.delete('public_holidays')
        save_yaml_contents
        
        # when I try to instantiate a HolidayCalendar from the file
        # I should get an exception
        err = assert_raise ArgumentError do
            cal = HolidayCalendar.new(:mode => :yaml, :filename => @yaml_filename)
        end
        assert_equal "YAML file #{@yaml_filename} does not have a 'public_holidays' setting", err.message
    end
    
    
    def test_exception_thrown_when_no_public_holiday_setting_in_yaml_file_is_not_an_array
        # given a yaml file with no weekend section
        setup_yaml_contents
        @yaml_contents['public_holidays'] = "Good Friday, Easter Monday"
        save_yaml_contents
        
        # when I try to instantiate a HolidayCalendar from the file
        # I should get an exception
        err = assert_raise ArgumentError do
            cal = HolidayCalendar.new(:mode => :yaml, :filename => @yaml_filename)
        end
        assert_equal "Invalid YAML file element 'public_holidays' - must be an Hash, is String", err.message
    end
    
    
    def test_that_holidays_are_setup_as_expected_from_yaml_file
        # given a yaml file
        setup_yaml_contents
        save_yaml_contents
        
        # when I instantiate a Holiday Calendar from it
        cal = HolidayCalendar.new(:mode => :yaml, :filename => @yaml_filename)
        # Then the first monday in may should be a public holiday
        assert_true cal.public_holiday?(Date.new(2009, 5, 4))
        
        # new Year's day should be a holiday
        assert_true cal.public_holiday?(Date.new(2009, 1, 1))
        
        # Good Friday should be a public holiday
        assert_true cal.public_holiday?(Date.new(2009, 4, 10))


        # saturdays and sundays should be weekends
        assert_true cal.weekend?(Date.new(2009, 8, 15))
        assert_true cal.weekend?(Date.new(2009, 8, 16))
        
        # evrything else should be a working day
        assert_true cal.working_day?(Date.new(2009, 8, 13))
        
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    def test_exception_raised_if_filename_specifies_non_existing_file_in_yaml_mode
        err = assert_raise ArgumentError do
            cal = HolidayCalendar.new(:mode => :yaml, :filename => 'i_do_not_exist.yaml')
        end
        assert_equal 'The filename specified in HolidayCalender.new cannot be found: i_do_not_exist.yaml', err.message
    end    
    

    def test_exception_raised_if_no_mode_parameter_passed_to_new
        err = assert_raise ArgumentError do
            cal = HolidayCalendar.new(:blah => :blah)
        end
        assert_equal 'No :mode parameter passed to HolidayCalendar.new', err.message
    end
    
    
    def test_exception_thrown_if_invalid_mode_parameter_passed_to_new
        err = assert_raise ArgumentError do
            cal = HolidayCalendar.new(:mode => :xxxx)
        end
        assert_equal 'Invalid :mode parameter passed to HolidayCalendar.new: :xxxx', err.message
    end
        
        
    def test_exception_thrown_if_unknown_option_passed_to_new
        err = assert_raise ArgumentError do
            cal = HolidayCalendar.new(:mode => :array, :invalid_option => :value)
        end
        assert_equal "Invalid key passed to HolidayCalendar.new in :array mode: invalid_option", err.message
    end        
        
        
    def test_exception_thrown_if_option_missing
        err = assert_raise ArgumentError do
            cal = HolidayCalendar.new(:mode => :array, :territory => :uk)
        end
        assert_equal "The following mandatory keys were not passed to HolidayCalendar.new in :array mode: weekend, specs", err.message
    end    
        
        
        
    
    
    def test_is_weekend_returns_true_for_weekends
           # given a working day schema where saturdays and sundays are weekends
           # when I ask whether a saturday is a weekend,I shoudl get true
           assert_true @cal.weekend?(Date.new(2009, 8, 15))
           assert_true @cal.weekend?(Date.new(2009, 8, 16))
           
           assert_false @cal.weekend?(Date.new(2009, 8, 14))
           assert_false @cal.weekend?(Date.new(2009, 8, 14))        
       end
       
       
       def test_public_holidays_are_recognised
           # given a working day schema with 8 public holidays
           # when I ask whether Christmas day is a public holiday, it should give true
           assert_true @cal.public_holiday?(Date.new(2007, 12, 25))
           
           # when I ask whether or not the 28th is a public holiday, it should give false
           assert_false @cal.public_holiday?(Date.new(2007, 12, 28))
    
           # when I ask whether Monday 7th May 2012 is a public holiday, it should reply true  (it's the first monday)
           assert_true @cal.public_holiday?(Date.new(2012, 5, 7))
           
           # when I ask if the next day is a public holiday it should say false
           assert_false @cal.public_holiday?(Date.new(2012, 5, 8))
           
           # when I ask if 26th November 2009 is a holiday, it should say true (it's the last thursday)
           assert_true @cal.public_holiday?(Date.new(2009, 11, 26))
           
           # but false for the next day
           assert_false @cal.public_holiday?(Date.new(2009, 11, 27))
       end
       
       
       
       def test_working_day_returns_false_if_its_a_weekend
           assert_false @cal.working_day?(Date.new(2009, 8, 15))            # Saturday
           assert_false @cal.working_day?(Date.new(2009, 8, 16))            # Sunday
       end
       
       
       def test_exception_raised_if_start_date_passed_to_count_working_days_between_not_before_end_date
           err = assert_raise ArgumentError do
                 @cal.count_working_days_between(Date.new(2009, 12, 25), Date.new(2009, 12, 24))      
           end
           assert_equal "start_date passed to HolidayCalendar.count_days_between() is not before end_date", err.message
       end
       
       
       
       def test_count_working_days_between_two_dates
           # given two dates Wed 23rd Dec and WEdnesday 30th Dec 2009
           start_date = Date.new(2009, 12, 23)
           end_date = Date.new(2009, 12, 30)
           
           # when I count the working days betwen them, it should give me 4 (Christmas day, Boxing Day and Saturday and Sunday are not working days)
           assert_equal 3, @cal.count_working_days_between(start_date, end_date)
       end
       
       
       
       def test_counting_forward_days_with_no_weekend
           start_date = Date.new(2009, 8, 10)              # monday
           target_end_date = Date.new(2009, 8, 14)         # friday
           
           assert_equal target_end_date, @cal.working_days_after(start_date, 4)
       end
       
       
       def test_counting_forward_days_with_weekend
           start_date = Date.new(2009, 8, 10)              # monday
           target_end_date = Date.new(2009, 8, 19)         # friday
    
           assert_equal target_end_date, @cal.working_days_after(start_date, 7)
       end        
       
                  
       
       def test_counting_backward_days_with_no_weekend
           start_date = Date.new(2009, 8, 14)              # friday
           target_end_date = Date.new(2009, 8, 10)         # monday
           
           actual_end_date = @cal.working_days_before(start_date, 4)
           assert_equal target_end_date, actual_end_date, "Target end date: #{target_end_date}, actual: #{actual_end_date}"
       end
       
       
       def test_counting_forward_with_weekend_and_holiday
           start_date = Date.new(2009, 4, 28)          # wed 29th apr
           target_end_date = Date.new(2009, 5, 6)      # wed 6th may  (monday 4th is holiday)
    
           actual_end_date = @cal.working_days_after(start_date, 5)
           assert_equal target_end_date, actual_end_date, "Target end date: #{target_end_date}, actual: #{actual_end_date}"
       end
       
end
        
        