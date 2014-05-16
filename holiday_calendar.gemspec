require File.dirname(__FILE__) + '/lib/holiday_calendar_version'


Gem::Specification.new do |s|
  s.name = %q{holiday_calendar}
  s.version = HOLIDAY_CALENDAR_VERSION
  s.authors = ["Stephen Richards"]
  s.email = ["holiday_calendar@stephenrichards.eu"]
  s.date = %q{2009-09-01}
  s.summary = %q{Dynamic and Configurable International Public Holiday Calendar}
  s.description = %q{Helper class for determining which days are public holidays in different countries, calcluating the working days between two dates, etc}
  s.files = `git ls-files -- {config,lib}/*`.split("\n")
  s.test_files = `git ls-files -- test/*`.split("\n")
  s.has_rdoc = true
  s.homepage = 'https://github.com/stephenrichards/holiday_calendar'
  s.extra_rdoc_files = ['config/uk_en.yaml',
                        'config/fr.yaml',
                        'config/us.yaml']
  s.rdoc_options   << "--main" << "README" <<
                      "--inline-source" <<
                      "--charset" << "UTF-8" <<
                      "--exclude" <<  "lib/modified_weekday.rb" <<
                      "--exclude" << "lib/public_holiday.rb" <<
                      "--exclude" << "test" <<
                      "--title" << "Holiday Calendar"
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.0}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2
  end
end
