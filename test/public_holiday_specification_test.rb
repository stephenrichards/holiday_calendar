
require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../lib/public_holiday_specification'
require File.dirname(__FILE__) + '/mocks/mock_public_holiday_specification'
require File.dirname(__FILE__) + '/../lib/religious_festival'


class PublicHolidaySpecificationTest < Test::Unit::TestCase
    
    def test_class_method_generates_valid_public_holiday_specification
        # given a specification that uses a class method
        phs = PublicHolidaySpecification.new(:name => 'Good Friday', :years => :all, :class_method => 'ReligiousFestival.good_friday')
        
        assert_instance_of PublicHolidaySpecification, phs
        assert_true phs.uses_class_method?
        assert_equal ReligiousFestival, phs.klass
        assert_equal 'good_friday', phs.method
        
    end
    
    
    


    
    ###
    ###
    ### tests against mock objects to confirm private attributes are being set up correctly
    ###
    ###
    
    def test_mock_object_created_with_single_year_generates_a_range_of_1_year_in_the_years_attribute
        # given an object created with a single year
        phs = MockPublicHolidaySpecification.new(:name => 'test', :years => 2006, :month => 12, :day => 25)

        # when I test the year, it should be a range 2006..2006
        assert_instance_of Range, phs.years
        assert_equal 2006..2006, phs.years
    end
    
    
    def test_mock_object_created_with_all_years_generates_a_range_of_all_years_in_the_years_attribute
        # given an object created with a all years
        phs = MockPublicHolidaySpecification.new(:name => 'test', :years => :all, :month => 12, :day => 25)

        # when I test the year, it should be a range 2006..2006
        assert_instance_of Range, phs.years
        assert_equal 0..9999, phs.years
    end        
    
    
    def test_mock_object_created_with_range_of_years_generates_the_correct_range_in_the_years_attribute
        # given an object created with a range of  years
        phs = MockPublicHolidaySpecification.new(:name => 'test', :years => 1997..2006, :month => 12, :day => 25)

        # when I test the year, it should be a range 2006..2006
        assert_instance_of Range, phs.years
        assert_equal 1997..2006, phs.years
    end        
    
    def test_mock_object_created_with_english_month_names_generates_the_correct_month_number_in_the_month_attribute
        # given an object created with a month of May
        phs = MockPublicHolidaySpecification.new(:name => 'test', :years => :all, :month => 'May', :day => :first_monday)
        
        # when I test the month, it should be 5
        assert_equal 5, phs.month
    end
    
    
    def test_mock_object_created_with_fixed_day_number_has_a_fixed_day_number_in_the_day_attribute
        # given an object created with a day number
        phs = MockPublicHolidaySpecification.new(:name => 'test', :years => 1997..2006, :month => 12, :day => 25)
        
        # when I test the day, it should be a fixnum 25            
        assert_instance_of Fixnum, phs.day
        assert_equal 25, phs.day
    end    
    
    
    def test_mock_object_created_with_first_monday_has_a_modified_weekday_object_as_the_day_attribute
        # given an object created with a phrase like :first_monday
        phs = MockPublicHolidaySpecification.new(:name => 'test', :years => :all, :month => 12, :day => :first_monday)
        
        # when I test the day, it should be a fixnum 25            
        assert_instance_of ModifiedWeekday, phs.day
    end
    
    
    
    
    ###
    ###
    ### tests that the constructor validates incoming parameters properly
    ###
    ###    
    
    def test_exception_thrown_if_mandatory_paramaters_missing
        err = assert_raise ArgumentError do
            phs = PublicHolidaySpecification.new(:name => 'test')
        end
        assert_equal "Mandatory parameters are missing in a call to PublicHolidaySpecification.new: years, month, day", err.message
    end
    
    
    
    def test_exception_thrown_if_invalid_paramaeter_passed_to_constructor
        
        err = assert_raise ArgumentError do
            phs = PublicHolidaySpecification.new(:name => 'Test Holiday', :invalid_param => 'xxxx')
        end
        
        assert_equal 'Invalid parameter passed to PublicHolidaySpecification.new: invalid_param => xxxx', err.message
    end
    
    
    def test_exception_thrown_if_invalid_year_passed_to_constructor
        err = assert_raise ArgumentError do
            phs = PublicHolidaySpecification.new(:name => 'Xmas', :years => :this_year, :month => 12, :day => 25)
        end
        assert_equal 'Invalid value passed as years parameter. Must be a Range, Fixnum or :all', err.message
    end
    
    
    def test_exception_thrown_if_invalid_month_passed_to_constructor
        err = assert_raise ArgumentError do
            phs = PublicHolidaySpecification.new(:name => 'Xmas', :years => :all, :month => 'décembre', :day => 25)
        end
        assert_equal 'Invalid month passed to PublicHolidaySpecification.new: décembre', err.message  
    end
    
              
    def test_exception_thrown_if_out_of_range_month_passed_to_constructor
        err = assert_raise ArgumentError do
            phs = PublicHolidaySpecification.new(:name => 'Xmas', :years => :all, :month => 33, :day => 25)
        end
        assert_equal 'Invalid month passed to PublicHolidaySpecification.new: 33', err.message  
    end        
    
    
    def test_exception_thrown_if_out_of_range_day_passed_to_constructor
        err = assert_raise ArgumentError do
            phs = PublicHolidaySpecification.new(:name => 'Xmas', :years => :all, :month => 12, :day => 125)
        end
        assert_equal 'Invalid value passed as :day parameter to PublicHolidaySpecification.new: 125', err.message  
    end        
    
    
    
end