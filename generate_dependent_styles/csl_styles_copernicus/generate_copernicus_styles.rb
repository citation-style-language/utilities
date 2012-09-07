#! /usr/bin/ruby

# for File.makedirs
require 'ftools'

# where are we?
This_script_path = File.dirname(File.expand_path(__FILE__))
puts "running script #{This_script_path}"

# hashes of hashes that will contain all the styles to generate
styles = { }

# template used by all the styles
template_path = "#{This_script_path}/copernicus_style_template.csl"
template = File.read(template_path)

# styles to skip
skip_list_path = "#{This_script_path}/copernicus_journals_to_skip.txt"
skipped_journals = File.read(skip_list_path).split(/\n/)

# start with new empty style directory
style_dir_path = "#{This_script_path}/generated_styles"
puts "creating directory at path #{style_dir_path}"
`rm -R '#{style_dir_path}'`
File.makedirs style_dir_path

# load all the info from the tab-delimited info file
journal_info = "#{This_script_path}/copernicus_journals.tab"
File.read(journal_info).split(/\n/).each do |journal_line|

  # each line has the following fields
  # Journal name	EISSN	ISSN	Category1	Category2
  fields = journal_line.split(/\t/)
  if (fields.length != 4 && fields.length != 5)
    puts "invalid journal line: #{journal_line}"
    next
  end
  title  = fields[0]
  eissn  = fields[1]
  issn   = fields[2]
  categ1 = fields[3]
  categ2 = fields[4]
  categ2 = '' if (fields.length == 4)
  
  # skip header of the tab delimited file
  next if title == 'Title'

  # skipped journals
  if (skipped_journals.include?(title))
    $stderr.puts "skipping journal: #{title} because it's in the exclusion list"
    next
  end

  # clean-up title: remove abbrevation in parenthesis
  title.gsub!(/ \(.*\)/, '') 

  # clean-up accidental extra spaces
  eissn.gsub!(' ', '')
  issn.gsub!('  ', ' ')
  categ1.gsub!('  ', ' ')
  categ2.gsub!('  ', ' ')

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

  # create style xml
  puts "creating style: #{identifier}"
  style_content = template.gsub('#TITLE#', title.gsub('&', '&amp;'))
  style_content.gsub!('#IDENTIFIER#', identifier)
  style_content.gsub!('#EISSN#', eissn)
  style_content.gsub!('#FIELD1#', categ1)
  
  if (issn.length == 9)
    style_content.gsub!('#OPTIONAL_ISSN#', "")
    style_content.gsub!('#ISSN#', issn)
  else
    style_content.gsub!(/#OPTIONAL_ISSN#.*$\n/, "")
  end

  if (categ2.length > 1)
    style_content.gsub!("#OPTIONAL_CATEGORY#", "")
    style_content.gsub!('#FIELD2#', categ2)
  else
    style_content.gsub!(/#OPTIONAL_CATEGORY#.*$\n/, "")
  end
  
  # save file
  style_path = "#{style_dir_path}/#{identifier}.csl"
  File.open(style_path, 'w') { |fileio| fileio.write style_content }
  
end