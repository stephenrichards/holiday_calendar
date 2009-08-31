require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../lib/public_holiday'
require File.dirname(__FILE__) + '/../lib/public_holiday_specification'
require File.dirname(__FILE__) + '/../lib/religious_festival'


class PublicHolidayTest < Test::Unit::TestCase
    
    def test_public_holiday_can_be_setup_correctly_from_a_specification_that_uses_a_class_method
        phs = PublicHolidaySpecification.new(:name => 'Good Friday', :years => :all, :class_method => 'ReligiousFestival.good_friday')

        ph = PublicHoliday.new(phs, 2008)
    
        assert_equal Date.new(2008, 3, 21), ph.date
    end
    
    
    
    def test_public_holiday_set_up_correctly_from_dated_specification
        phs = PublicHolidaySpecification.new(:name => 'test', :years => :all, :month => 12, :day => 25)
        
        ph = PublicHoliday.new(phs, 2009)
        assert_true ph.holiday?
        assert_equal Date.new(2009, 12, 25), ph.date
    end
   
   
    def test_public_holiday_holiday_returns_false_if_created_for_a_year_outside_the_range
        # given a holiday specification which only applies to one year
        phs = PublicHolidaySpecification.new(:name => 'test', :years => 2006, :month => 6, :day => 12) 
        
        # when I generate a public holiday for a different year
        ph = PublicHoliday.new(phs, 2007)
        
        # calling the holiday? method should return false
        assert_false ph.holiday?
    end
   
   
   
   def test_public_holiday_setup_correctly_from_last_thursday_expression_when_last_day_in_month_is_higher_wday_number_than_thursday
      # given a public holiday specification with an expression like last_thursday
      phs = PublicHolidaySpecification.new(:name => 'test', :years => :all, :month => 10, :day => :last_thursday) 
      
      # when I create a public holiday for a year where the last day of the month is a Friday or Saturday
      ph = PublicHoliday.new(phs, 2009)
      
      # it should calculate the last thursday in october 2009 correctly as the 29th
      assert_equal Date.new(2009, 10, 29), ph.date
       
   end
    
    
   def test_public_holiday_setup_correctly_from_last_thursday_expression_when_last_day_in_month_is_a_thursday
      # given a public holiday specification with an expression like last_thursday
      phs = PublicHolidaySpecification.new(:name => 'test', :years => :all, :month => 4, :day => :last_thursday) 

      # when I create a public holiday for a year where the last day of the month is a Thursday
      ph = PublicHoliday.new(phs, 2009)

      # it should calculate the last thursday in April 2009 correctly as the 30th
      assert_equal Date.new(2009, 4, 30), ph.date

   end       
    
    
   def test_public_holiday_setup_correctly_from_last_thursday_expression_when_last_day_in_month_is_lower_wday_number_than_thursday
      # given a public holiday specification with an expression like last_thursday
      phs = PublicHolidaySpecification.new(:name => 'test', :years => :all, :month => 5, :day => :last_thursday) 

      # when I create a public holiday for a year where the last day of the month is Sunday, Monday, Tuesday, Wednesday
      ph = PublicHoliday.new(phs, 2009)

      # it should calculate the last thursday in May 2009 correctly as the 28th
      assert_equal Date.new(2009, 5, 28), ph.date
   end    
    


    def test_public_holiday_setup_correctly_from_first_monday_expression_when_first_day_of_month_is_monday
       # given a public holiday specification with an expression like first_monday
       phs = PublicHolidaySpecification.new(:name => 'test', :years => :all, :month => 2, :day => :first_monday) 

       # when I create a public holiday for a year where the 1st Feb is a Monday
       ph = PublicHoliday.new(phs, 2010)

       # it should calculate the first Monday in Feb as 1st
       assert_equal Date.new(2010, 2, 1), ph.date
    end        
    
    
    def test_public_holiday_setup_correctly_from_first_monday_expression_when_first_day_of_month_is_thursday
       # given a public holiday specification with an expression like first_monday
       phs = PublicHolidaySpecification.new(:name => 'test', :years => :all, :month => 4, :day => :first_monday) 

       # when I create a public holiday for a year where the 1st April is Thursday
       ph = PublicHoliday.new(phs, 2010)

       # it should calculate the first Monday in Feb as 1st
       assert_equal Date.new(2010, 4, 5), ph.date
    end
    
    
    def test_public_holiday_setup_correctly_from_first_thursday_expression_when_first_day_of_month_is_sunday
       # given a public holiday specification with an expression like first_thursday
       phs = PublicHolidaySpecification.new(:name => 'test', :years => :all, :month => 8, :day => :first_thursday) 

       # when I create a public holiday for a year where the 1st August is Sunday
       ph = PublicHoliday.new(phs, 2010)

       # it should calculate the first Monday in Feb as 1st
       assert_equal Date.new(2010, 8, 5), ph.date
    end    
    
    
 
    def test_public_holiday_setup_correctly_from_third_monday_expression_when_first_day_of_month_is_monday
        # given a public holiday specification with an expression like first_monday
        phs = PublicHolidaySpecification.new(:name => 'test', :years => :all, :month => 2, :day => :third_monday) 

        # when I create a public holiday for a year where the 1st Feb is a Monday
        ph = PublicHoliday.new(phs, 2010)

        # it should calculate the first Monday in Feb as 1st
        assert_equal Date.new(2010, 2, 15), ph.date
    end        


    def test_public_holiday_setup_correctly_from_second_monday_expression_when_first_day_of_month_is_thursday
        # given a public holiday specification with an expression like first_monday
        phs = PublicHolidaySpecification.new(:name => 'test', :years => :all, :month => 4, :day => :second_monday) 

        # when I create a public holiday for a year where the 1st April is Thursday
        ph = PublicHoliday.new(phs, 2010)

        # it should calculate the first Monday in Feb as 1st
        assert_equal Date.new(2010, 4, 12), ph.date
    end


    def test_public_holiday_setup_correctly_from_fourth_thursday_expression_when_first_day_of_month_is_sunday
        # given a public holiday specification with an expression like first_thursday
        phs = PublicHolidaySpecification.new(:name => 'test', :years => :all, :month => 8, :day => :fourth_thursday) 

        # when I create a public holiday for a year where the 1st August is Sunday
        ph = PublicHoliday.new(phs, 2010)

        # it should calculate the first Monday in Feb as 1st
        assert_equal Date.new(2010, 8, 26), ph.date
    end  

    def test_to_s_works_as_it_should
        phs = PublicHolidaySpecification.new(:name => 'Late Summer Bank Holiday', :years => :all, :month => 8, :day => :fourth_thursday) 
        ph = PublicHoliday.new(phs, 2010)
        
        assert_equal "Thu 26 Aug 2010 : Late Summer Bank Holiday", ph.to_s
    end
        
    
    
    def test_must_be_taken_before_returns_true_for_day_numbers_in_the_taken_before_array
        # given a public holiday with days 4 and 5 in the taken_before array
        phs = PublicHolidaySpecification.new(:name => 'test', :years => :all, :month => 8, :day => 13, :take_before => [:thursday, :friday])
        ph  = PublicHoliday.new(phs, 2009)
        
        # when I call must_+be_taken_before?, it should return true
        assert_true ph.must_be_taken_before?
    end
    
    def test_must_be_taken_before_returns_false_for_day_numbers_in_the_taken_before_array
        # given a public holiday with days 4 and 5 in the taken_before array
        phs = PublicHolidaySpecification.new(:name => 'test', :years => :all, :month => 8, :day => 15, :take_before => [:thursday, :friday])
        ph  = PublicHoliday.new(phs, 2009)
        
        # when I call must_+be_taken_before?, it should return true
        assert_false ph.must_be_taken_before?
    end      
    
    def test_must_be_taken_after_returns_true_for_day_numbers_in_the_taken_before_array
        # given a public holiday with days 4 and 5 in the taken_before array
        phs = PublicHolidaySpecification.new(:name => 'test', :years => :all, :month => 8, :day => 13, :take_after => [:thursday, :friday])
        ph  = PublicHoliday.new(phs, 2009)
        
        # when I call must_+be_taken_before?, it should return true
        assert_true ph.must_be_taken_after?
    end
    
    def test_must_be_taken_after_returns_false_for_day_numbers_in_the_taken_before_array
        # given a public holiday with days 4 and 5 in the taken_before array
        phs = PublicHolidaySpecification.new(:name => 'test', :years => :all, :month => 8, :day => 15, :take_after => [:thursday, :friday])
        ph  = PublicHoliday.new(phs, 2009)
        
        # when I call must_+be_taken_before?, it should return true
        assert_false ph.must_be_taken_after?
    end  
    
end