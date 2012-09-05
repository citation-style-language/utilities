#! /usr/bin/ruby

# for File.makedirs
require 'ftools'

# where are we?
This_script_path = File.dirname(File.expand_path(__FILE__))
puts "running script #{This_script_path}"

# hashes of hashes that will contain all the styles to generate
styles = { }

# template used by all the styles
template_path = "#{This_script_path}/acm_style_template.csl"
template = File.read(template_path)

# styles to skip
skip_list_path = "#{This_script_path}/acm_journals_to_skip.txt"
skipped_journals = File.read(skip_list_path).split(/\n/)

# start with new empty style directory
style_dir_path = "#{This_script_path}/generated_styles"
puts "creating directory at path #{style_dir_path}"
`rm -R '#{style_dir_path}'`
File.makedirs style_dir_path

# load all the info from the tab-delimited info file
journal_info = "#{This_script_path}/acm_journals.tab"
File.read(journal_info).split(/\n/).each do |journal_line|

  # each line has the following fields
  # Title	eISSN	ISSN	Category1	Category2
  fields = journal_line.split(/\t/)
  if (fields.length != 5)
    puts "invalid journal line: #{journal_line}"
    next
  end
  title  = fields[0]
  eissn   = fields[1]
  issn  = fields[2]
  
  # skip header
  next if title =~ /^Title/
  
  # clean-up title to remove ACM prefix and abbbreviation suffix
  title.gsub!(/^ACM /, '')
  title.gsub!(/ \(.*\)/, '')

  # clean-up accidental extra spaces
  eissn.gsub!(' ', '')
  issn.gsub!('', '')
  
  # identifier is created from the title
  identifier = title.downcase
  identifier.gsub!(',', ' ')
  identifier.gsub!(':', ' ')
  identifier.gsub!("\'", '')
  identifier.gsub!('  ', ' ')
  identifier.gsub!('  ', ' ')
  identifier.gsub!(/^ +/, '')
  identifier.gsub!(/ +$/, '')
  identifier.gsub!(' ', '-')
  identifier.gsub!('--', '-')
  identifier.gsub!('--', '-')
  identifier.gsub!('&', 'and')

  # excluded journal?
  if (skipped_journals.include?(title) or skipped_journals.include?(identifier))
    $stderr.puts "skipping journal: #{title} because it's in the exclusion list"
    next
  end
  
  # create style xml
  puts "creating style: #{identifier}"
  style_content = template.gsub('#TITLE#', title.gsub('&', '&amp;'))
  style_content.gsub!('#IDENTIFIER#', identifier)
  
  # optional ISSN
  if (issn.length == 9)
    style_content.gsub!('#ISSN#', issn)
  else
    style_content.gsub!(/^.*#ISSN#.*$\n/, '')
  end

  # optional eISSN
  if (eissn.length == 9)
    style_content.gsub!('#EISSN#', eissn)
  else
    style_content.gsub!(/^.*#EISSN#.*$\n/, '')
  end
  
  # save file
  style_path = "#{style_dir_path}/#{identifier}.csl"
  File.open(style_path, 'w') { |fileio| fileio.write style_content }
  
end