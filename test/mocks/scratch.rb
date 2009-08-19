require 'yaml'

config = YAML.load_file(File.dirname(__FILE__) + '/../../config/uk.yaml')
require 'pp'
pp config
puts "***************************"
config = YAML.load_file(File.dirname(__FILE__) + '/../../config/fr.yaml')


require 'pp'
pp config

puts "***************************"
config = YAML.load_file(File.dirname(__FILE__) + '/../test.yaml')
pp config
puts "Noël"
