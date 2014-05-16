# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../lib/holiday_calendar'
require File.dirname(__FILE__) + '/../lib/public_holiday_specification'



class HolidayCalendarTest < Test::Unit::TestCase


    ########### setup methods

    def setup
        # # create a working day schema with three public holidays, and weekends on Saturday, Sunday
        @xmas    = PublicHolidaySpecification.new(
                        :name           => 'Christmas Day',
                        :years          => :all,
                        :month          => 12,
                        :day            => 25,
                        :take_after     => ['Saturday', 'Sunday'])

        @box     = PublicHolidaySpecification.new(
                        :name           => 'Boxing Day',
                        :years          => :all,
                        :month          => 12,
                        :day            => 26,
                        :take_after     => [0,6])

        @mayday  = PublicHolidaySpecification.new(
                        :name           => 'May Day',
                        :years          => :all,
                        :month          => 5,
                        :day            => :first_monday,
                        :take_after     => [:saturday, :sunday])

        @tg      = PublicHolidaySpecification.new(
                        :name           => 'Thanksgiving Day',
                        :years          => :all,
                        :month          => 11,
                        :day            => :last_thursday)

        @summer  = PublicHolidaySpecification.new(
                        :name           => 'Summer Bank Holiday',
                        :years          => :all,
                        :month          => 8,
                        :day            => :last_monday)

        @spring  = PublicHolidaySpecification.new(
                        :name           => 'Spring Bank Holiday',
                        :years          => :all,
                        :month          => 5,
                        :day            => :last_monday)

        @newyear = PublicHolidaySpecification.new(
                        :name           => "New Year's Day",
                        :years          => :all,
                        :month          => 1,
                        :day            => 1,
                        :take_after     => [:saturday, :sunday])

        @olympic = PublicHolidaySpecification.new(
                        :name           => 'Olympics Day',
                        :years          => 2012,
                        :month          => 8,
                        :day            => 12,
                        :take_after     => [:sunday],
                        :take_before    => [:saturday])

        @cal = HolidayCalendar.create(:uk, [0,6], [@xmas, @mayday, @tg, @box, @newyear, @spring, @olympic, @summer])
        @num_public_holidays = @cal.size

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


    def test_we_getting_the_version_under_test
        require File.dirname(__FILE__) + '/../lib/holiday_calendar_version'

        assert_equal HOLIDAY_CALENDAR_VERSION, HolidayCalendar.version
    end

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
        assert_true @cal.weekend_day_number?(0), 'Day 0 (Saturday) not recognised as a weekend'
        assert_true @cal.weekend_day_number?(6), 'Day 6 (Sunday) not recognised as a weekend'
        assert_false @cal.weekend_day_number?(1), 'Day 1 (Monday) recognised as a weekend'
    end



    def test_list_for_year_produces_exected_results
        # given @call setup as standard
        # when I call list_for_year
        # I should get an array of strings representing the holidays in date order

        expected  = Array.new
        expected << "Thu 01 Jan 2009 : New Year's Day"
        expected << "Mon 04 May 2009 : May Day"
        expected << "Mon 25 May 2009 : Spring Bank Holiday"
        expected << "Mon 31 Aug 2009 : Summer Bank Holiday"
        expected << "Thu 26 Nov 2009 : Thanksgiving Day"
        expected << "Fri 25 Dec 2009 : Christmas Day"
        expected << "Mon 28 Dec 2009 : Boxing Day (carried forward from Sat 26 Dec 2009)"

        assert_equal expected, @cal.list_for_year(2009)
    end


    def test_holiday_calendar_created_with_day_names_gives_expected_results
        # given a HolidayCalendar created with weekends specified as day names
        cal = HolidayCalendar.create(:test, ['Thursday', 'Friday'], [@xmas, @box])

        # when I read the weekend day numbers, they should be 4 and 5
        assert_equal [4,5], cal.weekend
    end


    def test_holiday_calendar_created_with_invalid_objects_throws_an_exception
        err = assert_raise ArgumentError do
          HolidayCalendar.create('string', ['x', 'y'], ['a', 'b', 'c'])
        end
        assert_equal 'territory must be specified as symbol in HolidayCalendar.create', err.message

        err = assert_raise ArgumentError do
          HolidayCalendar.create(:test, [45.3, 'y'], ['a', 'b', 'c'])
        end
        assert_equal 'Invalid weekend array passsed to HolidayCalendar.create: each day must be day number in range 0-6 or day name', err.message

        err = assert_raise ArgumentError do
          HolidayCalendar.create(:test, ['Saturday', 6], ['a', 'b', 'c'])
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
          HolidayCalendar.load_file(@yaml_filename)
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
          HolidayCalendar.load_file(@yaml_filename)
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
          HolidayCalendar.load_file(@yaml_filename)
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
          HolidayCalendar.load_file(@yaml_filename)
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
          HolidayCalendar.load_file(@yaml_filename)
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
          HolidayCalendar.load_file(@yaml_filename)
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


    def test_loading_from_french_std_config_gives_expected_results

        # given a holiday calendar loaded from a standard config for france
        cal = HolidayCalendar.load(:fr)

        # when I test french holiday dates, then they should be holidays
        nyd = Date.new(2010, 1, 1)
        assert_true cal.public_holiday?(nyd)
        assert_equal "Jour de l'An", cal.holiday_name(nyd)

        em = Date.new(2010, 4, 5)
        assert_true cal.public_holiday?(em)
        assert_equal 'Lundi de Pâques', cal.holiday_name(em)

        ld = Date.new(2009, 5, 1)
        assert_true cal.public_holiday?(ld)
        assert_equal 'Fête du Travail', cal.holiday_name(ld)

        ved = Date.new(2009, 5, 8)
        assert_true cal.public_holiday?(ved)
        assert_equal 'Fête de la Victoire 1945', cal.holiday_name(ved)

        ad = Date.new(2009, 5, 21)
        assert_true cal.public_holiday?(ad)
        assert_equal 'Ascension catholique', cal.holiday_name(ad)

        wm = Date.new(2009, 6, 1)
        assert_true cal.public_holiday?(wm)
        assert_equal 'Lundi de Pentecôte', cal.holiday_name(wm)

        fn = Date.new(2009, 7, 14)
        assert_true cal.public_holiday?(fn)
        assert_equal 'Fête nationale', cal.holiday_name(fn)

        ts = Date.new(2010, 11, 1)
        assert_true cal.public_holiday?(ts)
        assert_equal 'Toussaint', cal.holiday_name(ts)

        arm = Date.new(2009, 11, 11)
        assert_true cal.public_holiday?(arm)
        assert_equal "Armistice", cal.holiday_name(arm)

        xmas = Date.new(2009, 12, 25)
        assert_true cal.public_holiday?(xmas)
        assert_equal 'Noel', cal.holiday_name(xmas)
    end


    def test_loading_from_uk_std_config_gives_expected_results
        # given a holiday calendar loaded from a standard config for france
        cal = HolidayCalendar.load(:uk_en)

        # when I test UK holiday dates, then they should be holidays
        assert_true cal.public_holiday?(Date.new(2010, 1, 1))
        assert_equal "New Year's Day", cal.holiday_name(Date.new(2010, 1, 1))

        assert_true cal.public_holiday?(Date.new(2010, 4, 2))
        assert_equal "Good Friday", cal.holiday_name(Date.new(2010, 4, 2))

        assert_true cal.public_holiday?(Date.new(2010, 4, 5))
        assert_equal "Easter Monday", cal.holiday_name(Date.new(2010, 4, 5))

        assert_true cal.public_holiday?(Date.new(2010, 5, 3))
        assert_equal 'May Day', cal.holiday_name(Date.new(2010, 5, 3))

        assert_true cal.public_holiday?(Date.new(2010, 5, 31))
        assert_equal "Spring Bank Holiday", cal.holiday_name(Date.new(2010, 5, 31))

        assert_true cal.public_holiday?(Date.new(2010, 8, 30))
        assert_equal "Summer Bank Holiday", cal.holiday_name(Date.new(2010, 8, 30))

        assert_true cal.public_holiday?(Date.new(2010, 12, 27))
        assert_equal "Christmas Day (carried forward from Sat 25 Dec 2010)", cal.holiday_name(Date.new(2010, 12, 27))

        assert_true cal.public_holiday?(Date.new(2010, 12, 28))
        assert_equal "Boxing Day (carried forward from Sun 26 Dec 2010)", cal.holiday_name(Date.new(2010, 12, 28))
    end


    def test_take_before_when_take_before_means_last_day_of_previous_year
        # given a holiday of January 1st and is taken before if falling on a Saturday
        phs = PublicHolidaySpecification.new(:name => 'test', :years => :all, :day => 1, :month => 1, :take_before => [:saturday])
        cal = HolidayCalendar.create(:us, [0,6], [phs])

        # when I test to see if Friday 31st December 2010 is a holiday (1st Jan 2011 is a saturday)
        # it should say yes
        assert_true cal.public_holiday?(Date.new(2010, 12,31))
    end


    def test_loading_us_calendar_for_2009_gives_expected_results
        # given a holiday calendar loaded from the standard config for the US
        cal = HolidayCalendar.load(:us)

        # New Year's day dates for years 2009 - 2013
        nyd_dates = [ [2009,1,1],  [2010,1,1], [2010,12,31],  [2012,1,2],  [2013,1,1] ]
        assert_holidays nyd_dates, cal, "New Year's Day"

        mlk_dates = [ [2009,1,19], [2010,1,18], [2011,1,17], [2012,1,16], [2013,1,21 ]]
        assert_holidays mlk_dates, cal, 'Birthday of Martin Luther King, Jr.'

        wb_dates = [ [2009,2,16], [2010,2,15], [2011,2,21], [2012,2,20], [2013,2,18] ]
        assert_holidays wb_dates, cal, "Washington's Birthday"

        md_dates = [ [2009,5,25], [2010,5,31], [2011,5,30], [2012,5,28], [2013,5,27] ]
        assert_holidays md_dates, cal, 'Memorial Day'

        id_dates = [ [2009,7,3], [2010,7,5], [2011,7,4], [2012,7,4], [2013,7,4] ]
        assert_holidays id_dates, cal, 'Independence Day'

        ld_dates = [ [2009,9,7], [2010,9,6], [2011,9,5], [2012,9,3], [2013,9,2] ]
        assert_holidays ld_dates, cal, 'Labor Day'

        cd_dates = [ [2009,10,12], [2010,10,11], [2011,10,10], [2012,10,8], [2013,10,14] ]
        assert_holidays cd_dates, cal, 'Columbus Day'

        vd_dates = [ [2009,11,11], [2010,11,11], [2011,11,11], [2012,11,12], [2013,11,11] ]
        assert_holidays vd_dates, cal, "Veterans' Day"

        tgd_dates = [ [2009,11,26], [2010,11,25], [2011,11,24], [2012,11,22], [2013,11,28] ]
        assert_holidays tgd_dates, cal, "Thanksgiving Day"

        xmas_dates = [ [2009,12,25], [2010,12,24], [2011,12,26], [2012,12,25], [2013,12,25] ]
        assert_holidays xmas_dates, cal, "Christmas Day"
    end

#  [ [2009], [2010], [2011], [2012], [2013] ]


    def assert_holidays(holiday_dates, cal, holiday_name)
      holiday_dates.each do |holiday_date|
        date = arr2date(holiday_date)
        assert_true cal.public_holiday?(date), "#{date} not recognised as #{holiday_name}"
        assert_match(/^#{holiday_name}/, cal.holiday_name(date))
      end
    end


    def arr2date(array)
        Date.new(array[0], array[1], array[2])
    end


    def test_exception_raised_if_filename_specifies_non_existing_file_in_yaml_mode
        err = assert_raise ArgumentError do
          HolidayCalendar.load_file('i_do_not_exist.yaml')
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
        ph2 = PublicHolidaySpecification.new(:name => "Tony's Birthday", :years => :all, :month => 5, :day => 17, :take_after => [0,6])
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


    def test_adding_an_object_which_isnt_a_public_holiday_specification_throws_an_exception
        err = assert_raise ArgumentError do
            @cal << {:key1=> :val1, :key2 => :val2}
        end
        assert_equal(
            'you must pass a PublicHolidaySpecification or an array of PublicHolidaySpecification objects to << method of HolidayCalendar',
            err.message)
    end


    def test_adding_an_array_of_objects_that_arent_all_public_holiday_specications_throws_an_exception
        err = assert_raise ArgumentError do
            @cal << [@tg, @mayday, 'another Holiday', @xmas]
        end
        assert_equal(
            'you must pass a PublicHolidaySpecification or an array of PublicHolidaySpecification objects to << method of HolidayCalendar',
            err.message)
    end



    def test_deleting_a_holiday_works_as_expected
        # given the standard calendar which reports boxing day and Christmas day as a holiday and has seven public holidays
        assert_true @cal.public_holiday?(Date.new(2009, 12, 28)), '28 Dec 2009 (boxing Day carried forward) is not reported as a holiday'
        assert_true @cal.public_holiday?(Date.new(2011, 12, 26))
        assert_true @cal.public_holiday?(Date.new(2009, 12, 25))
        assert_equal @num_public_holidays, @cal.size

        # when I delete boxing day
        result = @cal.delete('Boxing Day')

        # then result should be true indicating that boxing day has been found
        # the number of public holidays should be decreased by 1
        # boxing day should no longer be a holiday but other holidays should remain
        assert_true result
        assert_equal @num_public_holidays - 1, @cal.size
        assert_false @cal.public_holiday?(Date.new(2009, 12, 28)), '28 Dec 2009 (boxing Day carried forward) is reported as a holiday after deletion'
        assert_false @cal.public_holiday?(Date.new(2012, 12, 26)), '26 Dec 2011 (boxing Day ) is reported as a holiday after deletion'
        assert_true @cal.public_holiday?(Date.new(2009, 12, 25)), 'Christmas day 2009 is not reported as a holiday after deletion of boxing day'
    end


    def test_attempting_to_delete_a_non_existent_public_holiday_results_in_false
        # given the standard calendar or 8 public holidays
        assert_equal @num_public_holidays, @cal.size

        # when I delete a holiday that doesn't exist
        result = @cal.delete('My Birthday')

        # the result should be false and the number of holidays should remain unchanged
        assert_false result
        assert_equal @num_public_holidays, @cal.size
    end




    def test_christmas_2010_gives_exected_results
        dates = {23 => true,
                 24 => true,
                 25 => false,
                 26 => false,
                 27 => false,
                 28 => false,
                 29 => true
            }

        dates.each do |day, expected|
            assert_equal expected, @cal.working_day?(Date.new(2010, 12, day)), "#{day} Dec 2010 expected public_holiday = #{expected} - was not"
        end
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
