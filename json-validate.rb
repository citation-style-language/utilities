#! /usr/bin/env ruby

require 'rubygems'
require 'json-schema'

# script takes a pattern of input; for example '/home/json/*.json'
jsfiles = Dir.glob(ARGV)
schema = 'csl-data.json'

jsfiles.each do |jsfile|
  begin
    JSON::Validator.validate!(schema, jsfile)
  rescue JSON::Schema::ValidationError
    puts "---"
    puts "Validation error(s) in: "+jsfile
    puts $!.message
  end
end
