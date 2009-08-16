
require File.dirname(__FILE__) + '/../../lib/public_holiday_specification'

class MockPublicHolidaySpecification < PublicHolidaySpecification
    
    attr_reader :years, :month, :day
end
    