files = Dir['*test.rb']
files.each do |f|
    require f
end