#! /usr/bin/ruby

# for FileUtils.mkdir_p
require 'fileutils'

# where are we?
This_script_dir = File.dirname(File.expand_path(__FILE__))
$stderr.puts "Running script: #{This_script_dir}"
$stderr.puts "\n"

# the 'data' directory contains info for each group of journals
# for instance:
#   data/bmc
#   data/bmc/_template.csl  --> template for those journals
#   data/bmc/_journals.tab  --> tab-delimited list of journals + info
#   data/bmc/_skip.txt      --> journals to skip
Data_dir_path = "#{This_script_dir}/data"
$stderr.puts "Styles will be generated from data at path: #{Data_dir_path}"
if not File.exist? Data_dir_path
  $stderr.puts "WARNING: no file at path '#{Data_dir_path}'"
  $stderr.puts "WARNING: cannot generate styles"
  abort "Failed"
end

# start with new empty style directory
generated_style_dir_path = "#{This_script_dir}/generated_styles"
`rm -R '#{generated_style_dir_path}'` if File.exist? generated_style_dir_path
$stderr.puts "Creating empty directory for the generated styles at path: #{generated_style_dir_path}"
FileUtils.mkdir_p generated_style_dir_path

# we can now iterate over each of the data subdirs
Dir.foreach(Data_dir_path) do |data_subdir|
  
  # skip invalid entries
  next if data_subdir =~ /^\./
  $stderr.puts "\n"
  $stderr.puts "Generating styles from subdirectory '#{data_subdir}'..."
  data_subdir_path = "#{Data_dir_path}/#{data_subdir}"
  template_path = "#{data_subdir_path}/_template.csl"
  journals_path = "#{data_subdir_path}/_journals.tab"
  skip_path     = "#{data_subdir_path}/_skip.txt"
  all_good = true
  [template_path, journals_path].each do |file_to_check|
    next if File.exist? file_to_check
    $stderr.puts "WARNING: missing file at path '#{file_to_check}'"
    all_good = false
  end
  unless all_good
    $stderr.puts "WARNING: cannot generate styles from directory '#{data_subdir}'"
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

  # iterate over each journal
  header_info = [ ]

  # load all the info from the tab-delimited info file
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
    identifier.gsub!('--', '-')
    identifier.gsub!('--', '-')
    identifier.gsub!('&', 'and')
    
    # for accents, it seems `tr` does not work very well as there seems to be some issue with how things are encoded
    identifier.gsub!('à', 'a')
    identifier.gsub!('á', 'a')
    identifier.gsub!('ä', 'a')
    identifier.gsub!('è', 'e')
    identifier.gsub!('é', 'e')
    identifier.gsub!('ë', 'e')
    identifier.gsub!('ö', 'o')
    identifier.gsub!('Ö', 'o')
    identifier.gsub!('ü', 'u')
    identifier.gsub!('ß', 'ss')
    
    field_values['TITLE'] = title.gsub('&', '&amp;') # XML escape
    field_values['IDENTIFIER'] = identifier

    # excluded journal?
    if (skipped_journals.include?(initial_title) or skipped_journals.include?(identifier))
      $stderr.puts "skipping journal: #{title} because it is in the exclusion list"
      next
    end
  
    # create style xml by replacing fields in the template
    $stderr.puts "creating style: #{identifier}"
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

end

