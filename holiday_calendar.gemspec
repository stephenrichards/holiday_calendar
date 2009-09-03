Gem::Specification.new do |s|
    s.name = %q{holiday_calendar}
    s.version = "1.0.9"

    s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
    s.authors = ["Stephen Richards"]
    s.date = %q{2009-09-01}
    #s.default_executable = %q{mindy}
    s.description = %q{Helper class for determining which days are public holidays in different countries, calcluating the working days between two dates, etc}
    s.email = ["holiday_calendar@stephenrichards.eu"]
    #s.executables = ["mindy"]
    s.files = [
            'README.rb',
            'lib/holiday_calendar.rb', 
            'lib/modified_weekday.rb', 
            'lib/public_holiday.rb', 
            'lib/public_holiday_specification.rb',
            'lib/religious_festival.rb', 
            'config/fr.yaml', 
            'config/uk.yaml', 
            'config/us.yaml'
        ]
    s.has_rdoc = true
    s.homepage = %q{http://www.stephenrichards.eu}
    s.extra_rdoc_files = [
        'README.rb',
        'config/uk.yaml',
        'config/fr.yaml',
        'config/us.yaml'
        ]    
    s.rdoc_options   << "--main" << "README.rb" <<
                      "--inline-source" <<
                      "--charset" << "UTF-8" <<
                      "--exclude" <<  "lib/modified_weekday.rb" <<
                      "--exclude" << "lib/public_holiday.rb" <<
                      "--exclude" << "test" <<
                      "--title" << "Holiday Calendar"
                     
    s.require_paths = ["lib"]
    s.rubygems_version = %q{1.3.0}
    s.summary = %q{Dynamic and Configurable International Public Holiday Calendar}
    s.test_files = [
            'test/holiday_calendar_test.rb',
            'test/modified_weekday_test.rb',
            'test/public_holiday_specification_test.rb',
            'test/public_holiday_test.rb',
            'test/religious_festival_test.rb',
            'test/test_helper.rb',
            "test/units.rb"]
    if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2


    end
end