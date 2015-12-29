#! /usr/bin/ruby

# for File.makedirs
require 'ftools'

# where are we?
This_script_dir = File.dirname(File.expand_path(__FILE__))
$stderr.puts "Running script: #{This_script_dir}"
$stderr.puts "\n"

# paths
raw_list = "#{This_script_dir}/journals_raw.tab"
final_list = "#{This_script_dir}/_journals.tab"
$stderr.puts "Input raw list at path : #{raw_list}"
$stderr.puts "Output raw list at path: #{final_list}"
if not File.exist? raw_list
  $stderr.puts "WARNING: no file at path '#{raw_list}'"
  $stderr.puts "WARNING: cannot generate final list"
  abort "Failed"
end

# load all the info from the raw list of journals
journal_strings = File.read(raw_list).split(/\n/)
header_info = [ ]
journal_hashes = [ ]
journal_strings.each do |journal_line|

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
    field_name = header_info[field_index]
    field_values[field_name] = fields[field_index]
  end
  journal_hashes.push field_values
  
end

# translation from Springer style names into the CSL style identifiers
csl_id_for_springer_styles = {
  "APA-NameYear"             =>    "springer-socpsych-author-date",
  "APA-Numbered"             =>    "springer-socpsych-brackets",
  "APS-NameYear"             =>    "springer-physics-author-date",
  "APS-Numbered"             =>    "springer-physics-brackets",
  "Basic-NameYear"           =>    "springer-basic-author-date",
  "Basic-Numbered"           =>    "springer-basic-brackets",
  "Chicago-NameYear"         =>    "springer-humanities-author-date",
  "Chicago-Numbered"         =>    "springer-humanities-brackets",
  "MathPhysSci-NameYear"     =>    "springer-mathphys-author-date",
  "MathPhysSci-Numbered"     =>    "springer-mathphys-brackets",
  "Vancouver-NameYear"       =>    "springer-vancouver-author-date",
  "Vancouver-Numbered"       =>    "springer-vancouver-brackets"
}

# create the final 'clean' list that can then be used by the general script `generate_styles_from_data.rb`
File.open(final_list, 'w') do |fileio|

  # header
  fields = [ "Title", "Abbreviation", "ISSN", "EISSN", "Parent", "Format", "Field" ]
  should_prepend_tab = false
  fields.each do |field_name|
    fileio.write "\t" if should_prepend_tab
    fileio.write field_name
    should_prepend_tab = true
  end
  fileio.write "\n"

  # journals
  journal_hashes.each do |journal_info|

    # parent style is derived from Springer-specific names for the bibliography and citation
    springer_name = "#{journal_info['Bibliography']}-#{journal_info['Citation']}"
    csl_id = csl_id_for_springer_styles[springer_name].to_s
    if (csl_id.length < 1)
      $stderr.puts "WARNING: skipping journal '#{journal_info["Title"]}' missing CSL identifier for the parent style"
      next
    end
    
    # <category citation-format="xxx"/>
    citation_format = ""
    citation_format = "author-date" if (journal_info['Citation'].eql?'NameYear')
    citation_format = "numeric"     if (journal_info['Citation'].eql?'Numbered')
    if (citation_format.length < 1)
      $stderr.puts "WARNING: skipping journal '#{journal_info["Title"]}' with unknown citation format '#{journal_info['Citation']}'"
      next
    end

    # <category field="xx"/>
    field = ""
    field = "psychology"   if (journal_info['Bibliography'].eql?'APA')
    field = "physics"      if (journal_info['Bibliography'].eql?'APS')
    field = "science"      if (journal_info['Bibliography'].eql?'Basic')
    field = "humanities"   if (journal_info['Bibliography'].eql?'Chicago')
    field = "science"      if (journal_info['Bibliography'].eql?'MathPhysSci')
    field = "medicine"     if (journal_info['Bibliography'].eql?'Vancouver')
    
    # output: unchanged fields, then the parent CSL identifier and citation format
    fields[0..-4].each do |field_name|
      fileio.write journal_info[field_name]
      fileio.write "\t"
    end
    fileio.write csl_id
    fileio.write "\t"
    fileio.write citation_format
    fileio.write "\t"
    fileio.write field
    fileio.write "\n"
    
  end
  
end

