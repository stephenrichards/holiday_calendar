require 'yaml'

config = YAML.load_file(File.dirname(__FILE__) + '/../test.yaml')

require 'pp'
pp config