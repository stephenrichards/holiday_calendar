# == HolidayCalendar
# 
# 
# HolidayCalendar is a library for determining public holidays in different countries.
#
# Its main features are:
# * Can load standard holiday calendars for UK (England), France, U.S. Federal Holidays
# * Can determine whether or not a particular day is a public holiday
# * Can return the name of a public holiday for a particular date
# * Can determine whether or not a date is a weekend
# * Can determine whether or not a date is a working day (i.e. not a weekend nor a public holiday)
# * Can determine the number of working days between two dates
# * Can determine the date a specified number of working days before or after a specified date
# * Users can define public holidays for other territories and add them into the calendar
#
#
#
# == Overview
# The library is made up of two main elements:
# * PublicHolidaySpecification
# * HolidayCalendar
#
# A PublicHolidaySpecification defines the name of the holiday, which years it applies to, when
# it is taken (e.g. 25th December or  third Thursday in November), and what to do if it falls on 
# a weekend (ee.g. nothing, take it the last working day before, take it the next working day after).
#
# A HolidayCalendar has a name (the territory for which it is valid), defines which days are weekends, 
# and contains an array of PublicHolidaySpecifications.  Given this data, the status of any date can be generated.
#
# A HolidayCalendar can be instantiated from the standard configurations distributed with this library, from a yaml
# file provided by the user, or from an array of PublicHolidaySpecification objects.
#
# == Example 
# This example loads the UK standard public holidays from the yaml file distributed with this gem.
# It then loads a second copy, but modifies it for Scotland by removing the Boxing Day holiday and adding a 2nd January holiday.
# Finally, various calls are made agains the two calendars.
#
#
#        
#        
#           require 'holiday_calendar'
#        
#           en      = HolidayCalendar.load(:uk)
#           sco     = HolidayCalendar.load(:uk)
#           sco.delete('Boxing Day')
#           sco << PublicHolidaySpecification.new(:name => "2nd Jan", :years => :all, :month => 1, :day => 2, :take_after => [:saturday, :sunday])
#        
#        
#           dates = [
#                    Date.new(2009,12,25),
#                    Date.new(2009,12,26),
#                    Date.new(2009,12,27),
#                    Date.new(2009,12,28),
#                    Date.new(2010,1,1),
#                    Date.new(2010,1,4)
#                ]
#        
#        
#           dates.each do |date|
#               if en.public_holiday?(date)
#                   puts "#{date} is a public holiday in England: #{en.holiday_name(date)}"
#               end
#               if sco.public_holiday?(date)
#                   puts "#{date} is a public holiday in Scotland: #{sco.holiday_name(date)}"
#               end
#           end
#        
#           puts "\n\nScottish Holidays in 2010"
#           puts "==========================="
#           hols = sco.list_for_year(2010)
#           hols.each { |h| puts h }
#
# == Feedback
#
# Feedback on this project is welcomed, particularly sets of rules for different countries, or useful additions.
# please mail me at dev@stephenrichards.eu
#
# Stephen Richards

        


