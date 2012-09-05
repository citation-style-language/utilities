#! /usr/bin/ruby

# for File.makedirs
require 'ftools'

# where are we?
This_script_path = File.dirname(File.expand_path(__FILE__))
puts "running script #{This_script_path}"

# hashes of hashes that will contain all the styles to generate
styles = { }

# template used by all the styles
template_path = "#{This_script_path}/bmc_style_template.csl"
template = File.read(template_path)

# styles to skip
skip_list_path = "#{This_script_path}/bmc_journals_to_skip.txt"
skipped_journals = File.read(skip_list_path).split(/\n/)

# start with new empty style directory
style_dir_path = "#{This_script_path}/generated_styles"
puts "creating directory at path #{style_dir_path}"
`rm -R '#{style_dir_path}'`
File.makedirs style_dir_path

# load all the info from the tab-delimited info file
journal_info = "#{This_script_path}/bmc_journals.tab"
File.read(journal_info).split(/\n/).each do |journal_line|

  # each line has the following fields
  # Publisher	Journal name	Abbreviation	ISSN	URL	Start Date
  fields = journal_line.split(/\t/)
  if (fields.length != 6)
    puts "invalid journal line: #{journal_line}"
    next
  end
  publisher = fields[0]
  title = fields[1]
  issn = fields[3]
  url = fields[4]
  year = fields[5]
  
  # identifier is created from the title
  identifier = title.downcase
  identifier.gsub!(',', ' ')
  identifier.gsub!(':', ' ')
  identifier.gsub!("\'", '')
  identifier.gsub!('  ', ' ')
  identifier.gsub!('  ', ' ')
  identifier.gsub!(' ', '-')
  identifier.gsub!('&', 'and')

  # only BMC journals actually use the common style
  if (publisher != 'BioMed Central Ltd')
    $stderr.puts "skipping journal: #{title} because publisher = #{publisher}"
    next
  end

  # only BMC journals actually use the common style
  if (skipped_journals.include?(title) or skipped_journals.include?(identifier))
    $stderr.puts "skipping journal: #{title} because it's in the exclusion list"
    next
  end
  
  # skip archived journals
  # only BMC journals actually use the common style
  if (year.to_i == 0)
    $stderr.puts "skipping journal: #{title} because year = #{year}"
    next
  end
  
  # create style xml
  puts "creating style: #{identifier}"
  style_content = template.gsub('#TITLE#', title.gsub('&', '&amp;'))
  style_content.gsub!('#IDENTIFIER#', identifier)
  style_content.gsub!('#URL#', url.gsub('&', '&amp;'))
  style_content.gsub!('#ISSN#', issn)
  
  # save file
  style_path = "#{style_dir_path}/#{identifier}.csl"
  File.open(style_path, 'w') { |fileio| fileio.write style_content }
  
end