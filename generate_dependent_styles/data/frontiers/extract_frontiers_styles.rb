#! /usr/bin/ruby

# for File.makedirs
require 'ftools'

# where are we?
This_script_path = File.dirname(File.expand_path(__FILE__))
puts "running script #{This_script_path}"

# output header
puts "Type\tTitle\tISSN\tParent Title\tParent ISSN\n"

# load all the info from the raw file
journal_info = "#{This_script_path}/frontiers_journals_raw.txt"
parent_title = ''
parent_eissn = ''
File.read(journal_info).split(/\n/).each do |journal_line|

  next if journal_line.length == 0

  # field or specialty
  is_field   = (journal_line.scan(/Field Chief Editor/).length > 0)
  is_special = (journal_line.scan(/Specialty Chief Editor/).length > 0)
  raise "error with field / special: #{journal_line}" if is_special == is_field
  type = is_field ? "Field" : "Specialty"

  # title
  captures = journal_line.scan(/^(Frontiers in [^•]+) •/)
  title = captures[0][0]
  parent_title = title if (is_field)

  # issn
  eissn = '-'
  if (journal_line =~ /ISSN/)
    captures = journal_line.scan(/ISSN: (\d{4}\-\d{3}(\d|x|X))/)
    eissn = captures[0][0]
  end
  parent_eissn = eissn if (is_field)
  
  raise "error with parent: #{journal_line}" if parent_title.length == 0
  raise "error with parent: #{journal_line}" if parent_eissn.length == 0

  # output line for that journal
  puts "#{type}\t#{title}\t#{eissn}\t#{parent_title}\t#{parent_eissn}"

end