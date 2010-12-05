require File.dirname(__FILE__) + '/../lib/work_time_schedule'
require File.dirname(__FILE__) + '/test_helper'
require 'test/unit'


class WorkTimeScheduleTest < Test::Unit::TestCase
    
    
    def setup
        calendar                   = HolidayCalendar.load(:uk_en)
        @schedule                  = WorkTimeSchedule.new(calendar, 9, 0, 17, 30)
        @christmas_day             = DateTime.new(2010, 12, 25, 11, 10, 0)
        @day_after_boxing_day_0900 = DateTime.new(2010, 12, 29, 9, 0, 0)
        @christmas_eve_1900        = DateTime.new(2010, 12, 24, 19, 0, 0)
        
        @sunday_1025               = DateTime.new(2010, 12, 5, 10, 25, 0)
        @monday_0845               = DateTime.new(2010, 12, 6, 8, 45, 0)
        @monday_0900               = DateTime.new(2010, 12, 6, 9, 0, 0)
        @monday_1025               = DateTime.new(2010, 12, 6, 10, 25, 0)
        @monday_1543               = DateTime.new(2010, 12, 6, 15, 43, 10)
        @monday_1730               = DateTime.new(2010, 12, 6, 17, 30, 0)
        @thursday_1025             = DateTime.new(2010, 12, 2, 10, 25, 0)
        @thursday_1730             = DateTime.new(2010, 12, 2, 17, 30, 0)
        @thursday_1812             = DateTime.new(2010, 12, 2, 18, 12, 0)
        @friday_0845               = DateTime.new(2010, 12, 3, 8, 45, 0)
        @friday_1812               = DateTime.new(2010, 12, 3, 18, 12, 0)
        @friday_0900               = DateTime.new(2010, 12, 3, 9, 0, 0)
        @friday_1025               = DateTime.new(2010, 12, 3, 10, 25, 0)
        @friday_1730               = DateTime.new(2010, 12, 3, 17, 30, 0)
        @saturday_1025             = DateTime.new(2010, 12, 4, 10, 25, 0)
        @saturday_1410             = DateTime.new(2010, 12, 4, 14, 10, 0)
    end

    
    
    def test_we_can_retrieve_workday_object
        friday = @schedule.workday(5)
        assert_instance_of WorkDay, friday
        assert_equal (9*60), friday.start_in_minutes
        assert_equal ((17*60) + 30), friday.end_in_minutes
    end
   
   
    def test_we_can_retrieve_a_weekend_workday_object
        sunday = @schedule.workday(6)
        assert_equal 0, sunday.start_in_minutes
        assert_equal 0, sunday.end_in_minutes
    end
    
    
    def test_we_can_set_new_times_for_a_particular_day_by_day_number
        @schedule.set_day(5, WorkTime.new(9, 0), WorkTime.new(17, 0))
        friday = @schedule.workday(5)
        assert_equal (9*60), friday.start_in_minutes
        assert_equal (17*60), friday.end_in_minutes
    end    
    
    
    def test_we_can_set_new_times_for_a_particular_day_by_day_name
        @schedule.friday(WorkTime.new(9, 0), WorkTime.new(16, 0))
        friday = @schedule.workday(5)
        assert_equal (9*60), friday.start_in_minutes
        assert_equal (16*60), friday.end_in_minutes
    end        
    
    
    def test_that_working_time_returns_false_for_public_holidays
        assert_false @schedule.working_time?(@christmas_day)
    end
    
    def test_that_working_time_returns_false_for_work_day_during_weekend
        assert_false @schedule.working_time?(@saturday_1410)
    end
    
    def test_that_working_time_returns_false_for_working_day_before_start_of_working_hours
        assert_false @schedule.working_time?(@friday_0845)
    end
    
    
    def test_that_working_time_returns_false_for_working_day_after_end_of_working_hours
        assert_false @schedule.working_time?(@friday_1812)
    end
    
    
    def test_next_working_day_always_gives_the_same_time_on_the_next_working_day
        assert_dates_equal @friday_1025, @schedule.next_working_day(@thursday_1025)
        assert_dates_equal @monday_1025, @schedule.next_working_day(@friday_1025)
    end
    
    
    def test_next_working_day_always_gives_the_next_working_day_even_if_its_a_weekend
        @schedule.saturday(WorkTime.new(9,0), WorkTime.new(12,30))      # make Saturday a half day
        assert_dates_equal @saturday_1025, @schedule.next_working_day(@friday_1025)
    end
    
    
    
    def test_that_working_time_returns_true_for_working_day_during_working_hours
        assert_true @schedule.working_time?(@friday_0900)
        assert_true @schedule.working_time?(@friday_1025)
        assert_true @schedule.working_time?(@friday_1730)
    end
        
        
    def test_that_start_of_day_returns_expected_value_for_working_day
        assert_dates_equal @friday_0900, @schedule.start_of_day(@friday_0845)
        assert_dates_equal @friday_0900, @schedule.start_of_day(@friday_1025)
        
        # but next working day if after end of work
        assert_dates_equal @monday_0900, @schedule.start_of_day(@friday_1812)
        
        # next working day if not a working day
        assert_dates_equal @monday_0900, @schedule.start_of_day(@sunday_1025)
    end
    
    
    def test_that_end_of_day_returns_expected_value_for_working_day   
        # during work time, should give the end of the working day
        assert_dates_equal @friday_1730, @schedule.end_of_day(@friday_1025)
        
        # after work time, should give the end of the working day
        assert_dates_equal @friday_1730, @schedule.end_of_day(@friday_1812)
        
        # before work time, should give the end of the previous working day
        assert_dates_equal @thursday_1730, @schedule.end_of_day(@friday_0845)
        assert_dates_equal @friday_1730, @schedule.end_of_day(@monday_0845)
        
        # on a non-working day, should give the end of the previous working day
        assert_dates_equal @friday_1730, @schedule.end_of_day(@sunday_1025)
    end
    
    
    def test_time_returns_time_if_during_working_hours_of_a_working_day
        assert_dates_equal @monday_1025, @schedule.time(@monday_1025)
    end
    
    
    def test_time_returns_start_of_working_day_if_before_start_on_working_day
        assert_dates_equal @friday_0900, @schedule.time(@friday_0845)
    end
    
    def test_time_returns_start_of_next_working_day_if_after_end_of_working_day
        assert_dates_equal @monday_0900, @schedule.time(@friday_1812)
    end
    
    def test_time_returns_start_of_next_working_day_if_not_a_working_day
        assert_dates_equal @monday_0900, @schedule.time(@saturday_1410)
        assert_dates_equal @day_after_boxing_day_0900, @schedule.time(@christmas_eve_1900)
    end
    
    
    def test_time_or_end_of_day_returns_expected_values
        # during working day, the same time should be returned
        assert_dates_equal @monday_1025, @schedule.time_or_end_of_day(@monday_1025)
        
        # after work hours, the end of working hours shoudl be returned
        assert_dates_equal @thursday_1730, @schedule.time_or_end_of_day(@thursday_1812)
        
        # on a non working day, the end of the previsou working day should be returned
        assert_dates_equal @friday_1730, @schedule.time_or_end_of_day(@sunday_1025)
    end
    
    
    
    
    def test_elapsed_minutes_between_two_periods_during_working_hours_on_the_same_day_returns_the_expected_result
        assert_equal 318, @schedule.elapsed_minutes(@monday_1025, @monday_1543)
    end
        

    def test_elapsed_minutes_between_time_during_working_hours_and_time_after_end_of_wokring_hours_on_the_same_day_gives_expected_result
        assert_equal 425, @schedule.elapsed_minutes(@friday_1025, @friday_1812)
        assert_equal 510, @schedule.elapsed_minutes(@friday_0845, @friday_1812)
    end
     
        
    def test_elapsed_minutes_between_time_before_working_hours_and_time_during_working_hours_gives_expected_result
        assert_equal 85, @schedule.elapsed_minutes(@friday_0845, @monday_1025)
    end
    
    
    # def test_elapsed_minutes_between_time_after_working_hours_and_time_during_working_hours_next_day
    #     assert_equal 85, @schedule.elapsed_minutes(@thursday_1812, @friday_1025)
    # end
    
    
    def test_private_method_time_to_end_of_day
        assert_equal 107, @schedule.send(:time_to_end_of_day, @monday_1543)
    end
    
    
    
    def test_private_method_year_day
        assert_equal 2010001, @schedule.send(:year_day, DateTime.new(2010, 1, 1, 15, 45, 0))
        assert_equal 2010337, @schedule.send(:year_day, @friday_1812)
        assert_equal 2010340, @schedule.send(:year_day, @monday_0900)
    end
    
    
    def test_private_method_to_modified_date
        expected = DateTime.new(2010, 12, 4, 0, 0, 0)
        actual = @schedule.send(:to_modified_date_time, DateTime.new(2010, 12, 4, 18, 12, 0), WorkTime.new(0,0))
        assert_equal expected, actual
    end
    
end

