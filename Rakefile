require 'rake'
require 'rake/testtask'

task :default => [:test]

desc 'Produce documentation'
task :doc do
    doc_dir = "#{File.dirname(__FILE__)}/doc"
    system "rm -r #{doc_dir}" if File.exist?(doc_dir)
    
    # system 'rdoc -x test -x lib/modified_weekday.rb -x lib/public_holiday.rb  -S -N -m README.rb'
    system 'rdoc --inline-source --charset=UTF-8 --exclude=.crt --exclude=.wdsl --exclude=.ru -x test -x lib/modified_weekday.rb -x lib/public_holiday.rb -m README.rb'
    

    puts "Documentation generation complete"
    puts "Documentation can be viewed at file://#{File.dirname(__FILE__)}/doc/index.html"
     
end


namespace :dev do
    
    desc 'Produce full documentation of all objects and private methods'
    task :doc do
        doc_dir = "#{File.dirname(__FILE__)}/doc"
        system "rm -r #{doc_dir}" if File.exist?(doc_dir)

        system 'rdoc -x test  -S -N -a -m README'
        puts "Documentation generation complete"
        puts "Documentation can be viewed at file://#{File.dirname(__FILE__)}/doc/index.html"

    end  
end      



namespace :gem do
    desc 'uninstalls the old gem, builds the new and installs it'
    task :install do
        system 'rm holiday_calendar-*'
        system 'gem uninstall holiday_calendar'
        system 'gem build holiday_calendar.gemspec'
        system 'gem install -l holiday_calendar'
    end
end


### the :test task
    
Rake::TestTask.new('test') do |t|
    t.pattern = 'test/*_test.rb'
    t.verbose = true
    t.warning = true
end