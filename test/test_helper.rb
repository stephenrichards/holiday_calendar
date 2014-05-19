require 'test/unit' 
require 'pp'
require 'date'
require_relative '../lib/holiday_calendar'



def assert_false(expression, message = nil)
    assert_equal false, expression, message
end


def assert_true(expression, message = nil)
    assert expression, message
end


def assert_dates_equal(expected, actual)
    assert_equal expected, actual, "Expected #{expected}: Got #{actual}"
end
