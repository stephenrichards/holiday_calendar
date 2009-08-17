require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../lib/religious_festival'


class ReligiousFestivalTest < Test::Unit::TestCase
    
    def test_easter_day_for_various_years
        assert_equal Date.new(2008, 3, 23), ReligiousFestival.easter(2008)
        assert_equal Date.new(2011, 4, 24), ReligiousFestival.easter(2011)
    end
    
    
    
    def test_good_friday
        assert_equal Date.new(2008, 3, 21), ReligiousFestival.good_friday(2008)
        assert_equal Date.new(2011, 4, 22), ReligiousFestival.good_friday(2011)
    end
    
    
    def test_easter_monday
        assert_equal Date.new(2008, 3, 24), ReligiousFestival.easter_monday(2008)
        assert_equal Date.new(2011, 4, 25), ReligiousFestival.easter_monday(2011)
    end        

end
