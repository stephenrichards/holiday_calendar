require File.dirname(__FILE__) + '/test_helper'
# require File.dirname(__FILE__) + '/../lib/modified_weekday'



class ModifiedWeekdayTest < Test::Unit::TestCase
    

    def test_that_two_modified_weekday_objects_created_with_the_same_expression_are_equal
        mw1 = ModifiedWeekday.new(:last_thursday)
        mw2 = ModifiedWeekday.new(:last_thursday)
        
        assert_equal mw1, mw2
    end
    
    
    def test_that_two_modified_weekday_objects_created_with_different_expressions_are_not_equal
        mw1 = ModifiedWeekday.new(:last_thursday)
        mw2 = ModifiedWeekday.new(:first_thursday)

        assert_not_equal mw1, mw2
    end        


    def test_that_modified_object_created_with_expressions_and_dates_are_equal
        # Given a ModifiedWeekday object created by an expression 
        mwe = ModifiedWeekday.new(:first_thursday)
        
        # and a ModifiedWeekday object created by date for a first thursday
        mwd = ModifiedWeekday.new(Date.new(2011,6,2))
        
        # when I compare them, they should be equal
        assert mwd == mwe
    end
    
    
    def test_that_a_modified_weekday_created_with_a_last_friday_expression_matches_one_created_with_a_date
        # Given a ModifiedWeekday object created by an expression 
        mwe = ModifiedWeekday.new(:last_friday)
        
        # and a ModifiedWeekday object created by date for a first thursday
        mwd = ModifiedWeekday.new(Date.new(2011,6,24))
        
        # when I compare them, they should be equal
        assert mwd == mwe        
        
    end





    def test_that_a_modified_weekday_object_with_last_modifier_can_be_properly_created
        mw = ModifiedWeekday.new(:last_thursday)
        assert_instance_of ModifiedWeekday, mw
        assert_equal :last, mw.modifier
        assert_equal :thursday, mw.weekday_name
        assert_equal 4, mw.wday
        assert_equal 0, mw.weekday_occurrance
        assert_equal true, mw.is_last
    end
    
    
    
    def test_that_a_modified_weekday_object_with_first_modifier_can_be_properly_created
        mw = ModifiedWeekday.new(:first_monday)
        assert_equal :first, mw.modifier
        assert_equal :monday, mw.weekday_name
        assert_equal 1, mw.wday
        assert_equal 1, mw.weekday_occurrance
        assert_equal false, mw.is_last
    end
    
    
    
    def test_that_first_wednesday_is_generated_from_wednesday_first_june_2011
        # given a date of 1/6/2011
        date = Date.new(2011, 6, 1)
        
        # when I create a modified date from it
        mw = ModifiedWeekday.new(date)

        # then it should be described as the first monday
        assert_equal :first_wednesday, mw.expression
        assert_equal :wednesday, mw.weekday_name
        assert_equal :first, mw.modifier
        assert_equal 1, mw.weekday_occurrance
        assert_equal false, mw.is_last
    end
    
    
    def test_that_first_thursday_is_generated_from_thursday_second_june_2011
        # given a date of 2/6/2011
        date = Date.new(2011, 6, 2)

        # when I create a modified date from it
        mw = ModifiedWeekday.new(date)

        # then it should be described as the first monday
        assert_equal :first_thursday, mw.expression
        assert_equal :thursday, mw.weekday_name
        assert_equal :first, mw.modifier
        assert_equal 1, mw.weekday_occurrance
        assert_equal false, mw.is_last
    end        
    
    
    def test_that_second_wednesday_is_generated_from_wednesday_eighth_june_2011
        # given a date of 2/6/2011
        date = Date.new(2011, 6, 8)

        # when I create a modified date from it
        mw = ModifiedWeekday.new(date)

        # then it should be described as the first monday
        assert_equal :second_wednesday, mw.expression
        assert_equal :wednesday, mw.weekday_name
        assert_equal :second, mw.modifier
        assert_equal 2, mw.weekday_occurrance
        assert_equal false, mw.is_last
    end        
    
    
    def test_that_second_thursday_is_generated_from_thursday_ninth_june_2011
        # given a date of 9/6/2011
        date = Date.new(2011, 6, 9)

        # when I create a modified date from it
        mw = ModifiedWeekday.new(date)

        # then it should be described as the first monday
        assert_equal :second_thursday, mw.expression
        assert_equal :thursday, mw.weekday_name
        assert_equal :second, mw.modifier
        assert_equal 2, mw.weekday_occurrance
        assert_equal false, mw.is_last
    end        
    
 
    def test_that_fourth_wednesday_is_generated_from_wednesday_22_june_2011
        # given a date of 22/6/2011
        date = Date.new(2011, 6, 22)

        # when I create a modified date from it
        mw = ModifiedWeekday.new(date)

        # then it should be described as the first monday
        assert_equal :fourth_wednesday, mw.expression
        assert_equal :wednesday, mw.weekday_name
        assert_equal :fourth, mw.modifier
        assert_equal 4, mw.weekday_occurrance
        assert_equal false, mw.is_last
    end   
    
    
    def test_that_last_wednesday_is_generated_from_wednesday_29_june_2011
        # given a date of 29/6/2011
        date = Date.new(2011, 6, 29)
        
        # when I create a modified weekday from it
        mw = ModifiedWeekday.new(date)
        
        # then it should be described as the fifth and last wednesday
        assert_equal :last_wednesday, mw.expression
        assert_equal :wednesday, mw.weekday_name
        assert_equal :last, mw.modifier
        assert_equal 5, mw.weekday_occurrance
        assert_equal true, mw.is_last
    end
    
    
    
    
    def test_that_an_invalid_weekday_raises_an_exception
        err = assert_raise ArgumentError do
            ModifiedWeekday.new(:second_wed)
        end
        assert_equal 'Invalid Weekday component passed to ModifiedWeekday.new: second_wed', err.message
    end

   
   def test_that_an_invalid_modifier_raises_an_exception
       err = assert_raise ArgumentError do
           ModifiedWeekday.new(:fifth_tuesday)
       end
       assert_equal 'Invalid weekday modifier passed to ModifiedWeekday.new: fifth_tuesday', err.message       
   end

    
    # def test_sort_values_are_generated_correctly
    #     assert_equal 11, ModifiedWeekday.new(:first_monday).sort_value
    #     assert_equal 12, ModifiedWeekday.new(:first_tuesday).sort_value
    #     assert_equal 23, ModifiedWeekday.new(:second_wednesday).sort_value
    #     assert_equal 44, ModifiedWeekday.new(:fourth_thursday).sort_value
    #     assert_equal 55, ModifiedWeekday.new(:last_friday).sort_value
    # end
        
    
    
    
end
