puts "Executing Unit Tests"

# files = Dir['*test.rb']
files = Dir[File.dirname(__FILE__) + '/*_test.rb']

files.each do |f|
    require f
end