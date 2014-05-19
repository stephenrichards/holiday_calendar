
require File.dirname(__FILE__) + '/test_helper'

require 'test/unit'

class WorkDayTest < Test::Unit::TestCase
    
    
    def test_can_instantiate_working_day
        wd = WorkDay.new(WorkTime.new(9,0), WorkTime.new(17,30))
        assert_true wd.working_day?
        assert_equal 540, wd.start_in_minutes
    end
    
    
    def test_can_intantiate_non_working_day
        wd = WorkDay.new(nil, nil)
        assert_false wd.working_day?
        assert_equal 0, wd.start_in_minutes
        assert_equal 0, wd.end_in_minutes
    end
    
end
