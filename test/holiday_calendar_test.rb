require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../lib/holiday_calendar'
require File.dirname(__FILE__) + '/../lib/public_holiday_specification'



class HolidayCalendarTest < Test::Unit::TestCase
    
  
    ########### setup methods
    
    def setup
        # # create a working day schema with three public holidays, and weekends on Saturday, Sunday
        @xmas    = PublicHolidaySpecification.new(:name => 'Christmas Day', :years => :all, :month => 12, :day => 25, :carry_forward => true)
        @box     = PublicHolidaySpecification.new(:name => 'Boxing Day', :years => :all, :month => 12, :day => 26, :carry_forward => true)
        @mayday  = PublicHolidaySpecification.new(:name => 'May Day', :years => :all, :month => 5, :day => :first_monday, :carry_forward => true)
        @tg      = PublicHolidaySpecification.new(:name => 'Thanksgiving Day', :years => :all, :month => 11, :day => :last_thursday)
        @summer  = PublicHolidaySpecification.new(:name => 'Summer Bank Holiday', :years => :all, :month => 8, :day => :last_monday)
        @spring  = PublicHolidaySpecification.new(:name => 'Spring Bank Holiday', :years => :all, :month => 5, :day => :last_monday)
        @newyear = PublicHolidaySpecification.new(:name => "New Year's Day", :years => :all, :month => 1, :day => 1, :carry_forward => true)
        @olympic = PublicHolidaySpecification.new(:name => 'Olympics Day', :years => 2012, :month => 8, :day => 12, :carry_forward => true)
        
        @cal = HolidayCalendar.create(:uk, [0,6], [@xmas, @mayday, @tg, @box, @newyear, @spring, @olympic, @summer])
                                           
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
    
    
    
    ############# tests for create method ####################
    
    def test_holiday_object_created_from_array_gives_expected_results
        # given a HolidayCalendar instantiated with the create method
        # @cal
        
        # when I query the object 
        # I should get expected results
        assert_true @cal.weekend?(Date.new(2009, 8, 22)), 'Saturday 22 Aug 2009 not recognised as a weekend'
        assert_true @cal.weekend?(Date.new(2009, 8, 23)), 'Sunday 23 Aug 2009 not recognised as a weekend'
        assert_false @cal.working_day?(Date.new(2009, 8, 22)), 'Saturday 22 Aug 2009 erroneously recognised as a working day'
        assert_true @cal.public_holiday?(Date.new(2009, 8, 31)), 'August Bank holiday not recognised as a public holiday'
        assert_false @cal.working_day?(Date.new(2009, 8, 31)), 'August Bank holiday erroneously recognised as a working day'
        assert_true @cal.public_holiday?(Date.new(2012, 8, 13)), 'August 13 2012 (Olympics day carried forward from 12th) not recognised as a public holiday'
        assert_false @cal.public_holiday?(Date.new(2011, 8, 13)), 'August 12 2011 erroneously recognised as a public holiday'
    end
    
    
    def test_holiday_calendar_created_with_day_names_gives_expected_results
        # given a HolidayCalendar created with weekends specified as day names
        cal = HolidayCalendar.create(:test, ['Thursday', 'Friday'], [@xmas, @box])

        # when I read the weekend day numbers, they should be 4 and 5
        assert_equal [4,5], cal.weekend
    end
    
    
    def test_holiday_calendar_created_with_invalid_objects_throws_an_exception
        err = assert_raise ArgumentError do
            cal = HolidayCalendar.create('string', ['x', 'y'], ['a', 'b', 'c'])
        end
        assert_equal 'territory must be specified as symbol in HolidayCalendar.create', err.message
        
        err = assert_raise ArgumentError do
            cal = HolidayCalendar.create(:test, [45.3, 'y'], ['a', 'b', 'c'])
        end
        assert_equal 'Invalid weekend array passsed to HolidayCalendar.create: each day must be day number in range 0-6 or day name', err.message        
        
        err = assert_raise ArgumentError do
            cal = HolidayCalendar.create(:test, ['Saturday', 6], ['a', 'b', 'c'])
        end
        assert_equal 'public holidays must be an array of PublicHolidaySpecification objects in HolidayCalendar.create', err.message        
    end
    
    
    
    
    
    
   ############### tests for load_file method
    
    def test_exception_thrown_when_no_territory_setting_supplied_in_yaml_file
        # given a yaml file with no territory section
        setup_yaml_contents
        @yaml_contents.delete('territory')
        save_yaml_contents
        
        # when I try to instantiate a HolidayCalendar from the file
        # I should get an exception
        err = assert_raise ArgumentError do
            cal = HolidayCalendar.load_file(@yaml_filename)
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
            cal = HolidayCalendar.load_file(@yaml_filename)
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
            cal = HolidayCalendar.load_file(@yaml_filename)
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
            cal = HolidayCalendar.load_file(@yaml_filename)
        end
        assert_equal "Invalid day specified as weekend: subbota", err.message
    end        
    
    
    def test_weekend_day_names_are_translated_into_correct_day_numbers
        # given a yaml file with no weekend section
        setup_yaml_contents
        save_yaml_contents
    
        # when I instantiate a HolidayCalendar from a yaml file
        cal = HolidayCalendar.load_file(@yaml_filename)
    
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
            cal = HolidayCalendar.load_file(@yaml_filename)
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
            cal = HolidayCalendar.load_file(@yaml_filename)
        end
        assert_equal "Invalid YAML file element 'public_holidays' - must be an Hash, is String", err.message
    end
    
    
     def test_that_holidays_are_setup_as_expected_from_yaml_file
         # given a yaml file
         setup_yaml_contents
         save_yaml_contents
         
         # when I instantiate a Holiday Calendar from it
         cal = HolidayCalendar.load_file(@yaml_filename)
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
     
    
    
    ################## test load method
    
    
    def test_loading_from_std_config_gives_expected_results
        # given a holiday calendar loaded from a standard config for france
        cal = HolidayCalendar.load(:fr)
        
        # when I test french holiday dates, then they should be holidays
        assert_true cal.public_holiday?(Date.new(2009, 7, 14))
        assert_true cal.public_holiday?(Date.new(2008,1,1))
    end
              
    

    def test_exception_raised_if_filename_specifies_non_existing_file_in_yaml_mode
        err = assert_raise ArgumentError do
            cal = HolidayCalendar.load_file('i_do_not_exist.yaml')
        end
        assert_equal 'The filename specified in HolidayCalender.new cannot be found: i_do_not_exist.yaml', err.message
    end    
    
    
    
    def test_adding_one_extra_holiday_works_as_expected
        # given a Holiday Calendar which has been queried for 2009 and 2012
        assert_true @cal.public_holiday?(Date.new(2009, 12, 25))
        assert_false @cal.public_holiday?(Date.new(2012, 2, 1))
        
        # when I add an extra holiday
        @cal << PublicHolidaySpecification.new(:name => 'My Birthday', :years => :all, :month => 8, :day => 13)

        # then that day should be a holiday in years that have previously been queried and other years
        assert_true @cal.public_holiday?(Date.new(2009, 8, 13))
        assert_true @cal.public_holiday?(Date.new(2010, 8, 13))
        assert_true @cal.public_holiday?(Date.new(2012, 8, 13))
    end
        
        
    def test_adding_an_array_of_extra_holidays_works_as_exptected
        # given a Holiday Calendar which has been queried for 2009 and 2012
        assert_true @cal.public_holiday?(Date.new(2009, 12, 25))
        assert_false @cal.public_holiday?(Date.new(2012, 2, 1))

        # when I add an array of extra holidays
        ph1 = PublicHolidaySpecification.new(:name => 'My Birthday', :years => :all, :month => 8, :day => 13)
        ph2 = PublicHolidaySpecification.new(:name => "Tony's Birthday", :years => :all, :month => 5, :day => 17, :carry_forward => false)
        ph3 = PublicHolidaySpecification.new(:name => "Charles' Birthday", :years => :all, :month => 4, :day => 3)
        @cal << [ph1, ph2, ph3]
        
        # then that those days should be a holiday in years that have previously been queried and other years
        assert_true @cal.public_holiday?(Date.new(2009, 8, 13))
        assert_true @cal.public_holiday?(Date.new(2010, 8, 13))
        assert_true @cal.public_holiday?(Date.new(2012, 8, 13))
        assert_true @cal.public_holiday?(Date.new(2010, 5, 17))
        assert_true @cal.public_holiday?(Date.new(2012, 5, 17))     
        assert_true @cal.public_holiday?(Date.new(2009, 4, 3))
        assert_true @cal.public_holiday?(Date.new(2012, 4, 3))   
        
        # and the pre-existing holidays should still be recognised as such
        assert_true @cal.public_holiday?(Date.new(2011, 12, 26))    
        
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
    
    
    
    def test_holiday_name_returns_expected_holiday_name
        assert_equal 'Christmas Day', @cal.holiday_name(Date.new(2009, 12, 25))
        assert_equal 'Boxing Day (carried forward from Sat 26 Dec 2009)', @cal.holiday_name(Date.new(2009, 12, 28))
        assert_equal 'Boxing Day', @cal.holiday_name(Date.new(2009, 12, 28), false)
        assert_nil @cal.holiday_name(Date.new(2008, 8, 21))
    end
    
end
        
        