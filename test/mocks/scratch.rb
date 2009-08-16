require 'yaml'

config = YAML.load_file(File.dirname(__FILE__) + '/../../config/uk.yaml')

require 'pp'
pp config