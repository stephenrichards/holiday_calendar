require File.dirname(__FILE__) + '/../lib/work_time.rb'
require File.dirname(__FILE__) + '/test_helper'

require 'test/unit'

class WorkTimeTest < Test::Unit::TestCase
    
    
    def test_times_less_than_1_oclock_give_correct_number_of_minutes
       wt = WorkTime.new(0,25)
       assert_equal 25, wt.minutes
    end

    def test_times_at_end_of_day_give_correct_number_of_minutes
        wt = WorkTime.new(23,59)
        assert_equal 1439, wt.minutes
    end
    
    def test_subtracton_gives_expected_result
        end_time = WorkTime.new(18,30)
        start_time = WorkTime.new(17,45)
        assert_equal 45, end_time - start_time
    end

    def test_compare_works_as_expected
        wt1025  = WorkTime.new(10, 25)
        wt1025a = WorkTime.new(10, 25)
        wt0845  = WorkTime.new(8, 45)
        wt1026  = WorkTime.new(10, 26)
        assert_true wt1025 == wt1025a
        assert_true wt1025 < wt1026
        assert_true wt1026 > wt0845
    end


    def test_negative_hours_raises_exception
        err = assert_raise RuntimeError do
            wt = WorkTime.new(-3, 30)
        end
        assert_equal 'Hours must be in range 0-23', err.message
    end
    
    def test_out_of_range_hours_raises_exception
        err = assert_raise RuntimeError do
            wt = WorkTime.new(24, 24)
        end
        assert_equal 'Hours must be in range 0-23', err.message
    end    
    

    def test_negative_minutes_raises_exception
        err = assert_raise RuntimeError do
            wt = WorkTime.new(3, -30)
        end
        assert_equal 'Minutes must be in range 0-59', err.message
    end
    
    def test_out_of_range_hours_raises_exception
        err = assert_raise RuntimeError do
            wt = WorkTime.new(6, 61)
        end
        assert_equal 'Minutes must be in range 0-59', err.message
    end      
end
