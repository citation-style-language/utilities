#! /usr/bin/ruby
# encoding: utf-8

# for FileUtils.mkdir_p
require 'fileutils'

# where are we?
This_script_dir = File.dirname(File.expand_path(__FILE__))
$stderr.puts "Script:\t#{This_script_dir}"

# the 'data' directory contains info for each group of journals
# for instance:
#   data/bmc
#   data/bmc/_template.csl  --> template for those journals
#   data/bmc/_journals.tab  --> tab-delimited list of journals + info
#   data/bmc/_skip.txt      --> journals to skip
#   data/bmc/_rename.tab    --> journal identifiers to rename
Data_dir_path = "#{This_script_dir}/data"
$stderr.puts "Input:\t#{Data_dir_path}"
if not File.exist? Data_dir_path
  $stderr.puts "WARNING: no file at path '#{Data_dir_path}'"
  $stderr.puts "WARNING: cannot generate styles"
  abort "Failed"
end

# start with new empty style directory
generated_style_dir_path = "#{This_script_dir}/generated_styles"
`rm -R '#{generated_style_dir_path}'` if File.exist? generated_style_dir_path
$stderr.puts "Output:\t#{generated_style_dir_path}"
$stderr.puts "\n"
$stderr.puts "Generating styles..."
FileUtils.mkdir_p generated_style_dir_path

# we can now iterate over each of the data subdirs
total_count_created_styles = 0
Dir.foreach(Data_dir_path) do |data_subdir|

  # skip invalid entries
  next if data_subdir =~ /^\./
  data_subdir_path = "#{Data_dir_path}/#{data_subdir}"
  template_path = "#{data_subdir_path}/_template.csl"
  journals_path = "#{data_subdir_path}/_journals.tab"
  skip_path     = "#{data_subdir_path}/_skip.txt"
  rename_path   = "#{data_subdir_path}/_rename.tab"
  all_good = true
  [template_path, journals_path].each do |file_to_check|
    next if File.exist? file_to_check
    $stderr.puts "WARNING for '#{data_subdir}': missing file at path '#{file_to_check}'"
    all_good = false
  end
  unless all_good
    $stderr.puts "WARNING for '#{data_subdir}': cannot generate styles from directory"
    next
  end

  # create subdir for the generated styles
  FileUtils.mkdir_p "#{generated_style_dir_path}/#{data_subdir}"

  # hashes of hashes that will contain all the styles to generate
  styles = { }

  # load data into strings
  template = File.read(template_path)
  journals = File.read(journals_path).split(/\n/)
  skipped_journals = [ ]
  skipped_journals = File.read(skip_path).split(/\n/) if File.exist? skip_path
  renamed_journals = [ ]
  renamed_journals = File.read(rename_path).split(/\n/) if File.exist? rename_path

  # parse renamed_journals file
  old_and_new_names = Hash.new
  renamed_journals.each do |renamed_journals_line|
    fields = renamed_journals_line.split(/\t/)
    if (fields.length == 2)
      old_and_new_names[fields[0]]=fields[1]
    end
  end

  # iterate over each journal
  header_info = [ ]

  # load all the info from the tab-delimited info file
  count_created_styles = 0
  count_skipped_styles = 0
  journals.each do |journal_line|

    # each line contains tab-delimited fields
    fields = journal_line.split(/\t/)
    count_fields = fields.length

    # first line = the header
    if (header_info.length == 0)
      header_info = fields
      next
    end

    # sanity check
    if (count_fields != header_info.length)
      $stderr.puts "WARNING: journal info has the wrong number of fields (#{fields.join(', ')})"
      next
    end

    # create hash from the field values
    field_values = { }
    (0..count_fields-1).each do |field_index|
      field_name = header_info[field_index].upcase
      field_values[field_name] = fields[field_index]
    end

    # more sanity check
    mandatory_fields = [ 'TITLE' ]
    fields_all_good = true
    mandatory_fields.each do |field_name_to_check|
      next if (field_values.has_key? field_name_to_check and field_values[field_name_to_check].length > 1)
      fields_all_good = false
      $stderr.puts "WARNING: journal info is missing field '#{field_name_to_check}': (#{fields.join(', ')})"
    end
    next if not fields_all_good

    # keep track of initial value of title to compare to the skip list
    initial_title = field_values['TITLE']

    # remove abbreviation in parenthesis that sometimes follow a title
    title = initial_title.gsub(/ \(.*\)/, '')

    # replace en-dashes in title by hyphens
    title = title.gsub('–', '-')

    # identifier is created from the title
    identifier = title.downcase
    identifier.gsub!(',', ' ')
    identifier.gsub!(':', ' ')
    identifier.gsub!("/", ' ')
    identifier.gsub!("+", ' ')
    identifier.gsub!(".", ' ')
    identifier.gsub!("\'", '')
    identifier.gsub!('  ', ' ')
    identifier.gsub!('  ', ' ')
    identifier.gsub!(/^ +/, '')
    identifier.gsub!(/ +$/, '')
    identifier.gsub!(' ', '-')
    identifier.gsub!('-&-', '-and-')
    identifier.gsub!('&', '-and-')
    identifier.gsub!('–', '-')
    identifier.gsub!('--', '-')
    identifier.gsub!('--', '-')
    identifier.gsub!('---', '-')

    # for accents, it seems `tr` does not work very well as there seems to be some issue with how things are encoded
    identifier.gsub!('à', 'a')
    identifier.gsub!('á', 'a')
    identifier.gsub!('ä', 'a')
    identifier.gsub!('è', 'e')
    identifier.gsub!('é', 'e')
    identifier.gsub!('ë', 'e')
    identifier.gsub!('í', 'i')
    identifier.gsub!('ó', 'o')
    identifier.gsub!('č', 'c')
    identifier.gsub!('É', 'E')
    identifier.gsub!('ń', 'n')
    identifier.gsub!('É', 'E')
    identifier.gsub!('ö', 'o')
    identifier.gsub!('Ö', 'o')
    identifier.gsub!('ü', 'u')
    identifier.gsub!('ß', 'ss')
    identifier.gsub!('’', '')
    identifier.gsub!('E', 'e')
    identifier.gsub!('?', '')
    identifier.gsub!('ę', 'e')
    identifier.gsub!('(', '')
    identifier.gsub!(')', '')
    identifier.gsub!('ą', 'a')
    identifier.gsub!('ñ', 'n')

    identifier.gsub!('ç', 'c')
    identifier.gsub!('', '')

    field_values['TITLE'] = title.gsub('&', '&amp;') # XML escape

    if field_values.has_key?("DOCUMENTATION")
      field_values['DOCUMENTATION'] = field_values['DOCUMENTATION'].gsub('&', '&amp;') # XML escape
    end
    
    field_values['XML-COMMENT'] = "Generated with https://github.com/citation-style-language/utilities/tree/master/generate_dependent_styles/data/#{data_subdir}"

    # replace identifier if in renamed_journals file
    if (old_and_new_names.has_key?(identifier))
      identifier = old_and_new_names[identifier]
    end

    field_values['IDENTIFIER'] = identifier

    # excluded journal?
    if (skipped_journals.include?(initial_title) or skipped_journals.include?(identifier))
      #$stderr.puts "excluded journal: #{title}"
      count_skipped_styles = count_skipped_styles + 1
      next
    end

    # create style xml by replacing fields in the template
    # $stderr.puts "creating style: #{identifier}"
    count_created_styles = count_created_styles + 1
    style_xml = "#{template}"
    field_values.each do |name, value|
      placeholder = "##{name}#"
      if value.length > 2
        # the value is valid --> replace the corresponding placeholder in the template
        style_xml.gsub! placeholder, value
      else
        # the value is empty (or 1 character) --> remove the entire line from the template
        style_xml.gsub! /^.*#{placeholder}.*$\n/, ''
      end
    end

    # save file
    style_path = "#{generated_style_dir_path}/#{data_subdir}/#{identifier}.csl"
    File.open(style_path, 'w') { |fileio| fileio.write style_xml }

  end

  if (count_skipped_styles == 0)
    $stderr.puts "Generated #{count_created_styles}\t\t\t#{data_subdir}"
  else
    $stderr.puts "Generated #{count_created_styles}\tSkipped #{count_skipped_styles}\t#{data_subdir}"
  end
  total_count_created_styles = total_count_created_styles + count_created_styles

end

$stderr.puts "\nDone! #{total_count_created_styles} dependent CSL styles generated."
