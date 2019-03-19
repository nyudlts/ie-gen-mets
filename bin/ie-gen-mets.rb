#------------------------------------------------------------------------------
# script generates METS files for NYU DLTS Intellectual Entities
#
# invocation:
# - see "print_usage" method
#
# preconditions:
# - see "README.md" file
#
# code flow:
# - assert that all required files are present
# - emit each portion of the METS document to stdout
#------------------------------------------------------------------------------
PART_DELIMITER  = ':'
UNAVAILABLE_STR = 'UNAVAIL'

class Part
  attr_reader :mptr, :orderlabel
  def initialize(str)
    x, @orderlabel = str.split(PART_DELIMITER,2)
    @mptr = (x == UNAVAILABLE_STR ? nil : x)
  end
end

#------------------------------------------------------------------------------
# XML emit methods:
#------------------------------------------------------------------------------
def emit_template_version
  puts '  <?ie-wip-template version="info:nyu/dl/v1.0/templates/ie/wip/v0.0.1"?>'
end

def emit_alt_record_id(h)
  puts %Q|        <altRecordID TYPE="#{h[:type]}">#{h[:id]}</altRecordID>|
end

def emit_xml_header
  puts <<'HERE_DOC_EOF'
<?xml version="1.0" encoding="UTF-8"?>
HERE_DOC_EOF
end

def emit_mets_open(obj_id)
  puts <<-'HERE_DOC_EOF'
<mets xmlns="http://www.loc.gov/METS/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/version191/mets.xsd" xmlns:xlink="http://www.w3.org/1999/xlink"
  HERE_DOC_EOF

  puts %{    xmlns:mods="http://www.loc.gov/mods/v3" OBJID="#{obj_id}">}
end

def emit_mets_close
  puts "</mets>"
end

def emit_mets_hdr(create  = Time.now.utc.strftime("%FT%TZ"),
                  lastmod = Time.now.utc.strftime("%FT%TZ"),
                  status  = "DRAFT")
  puts %{  <metsHdr CREATEDATE="#{create}" LASTMODDATE="#{lastmod}" RECORDSTATUS="#{status}">}
  puts <<-HERE_DOC_EOF
        <agent ROLE="DISSEMINATOR" TYPE="ORGANIZATION">
            <name>New York University Libraries</name>
        </agent>
        <agent ROLE="CREATOR" TYPE="INDIVIDUAL">
            <name>Joseph G. Pawletko</name>
        </agent>
    </metsHdr>
  HERE_DOC_EOF
end

def emit_mets_hdr_open(create  = Time.now.utc.strftime("%FT%TZ"),
                  lastmod = Time.now.utc.strftime("%FT%TZ"),
                  status  = "DRAFT")
  puts %|  <metsHdr CREATEDATE="#{create}" LASTMODDATE="#{lastmod}" RECORDSTATUS="#{status}">|
end

def emit_mets_hdr_close
  puts "  </metsHdr>"
end

def emit_agent(h)
  puts %Q{        <agent ROLE="#{h[:role]}" TYPE="#{h[:type]}"> }
  puts %Q{            <name>#{h[:name]}</name> }
  puts %Q{        </agent>}
end

def emit_dmd_marcxml(fname)
  puts %{    <dmdSec ID="dmd-00000001">}
  puts %{        <mdRef LOCTYPE="URL" MDTYPE="OTHER" OTHERMDTYPE="MARCXML" xlink:type="simple" xlink:href="#{fname}"/>}
  puts %{    </dmdSec>}
end

def emit_dmd_mods(fname)
  puts %{    <dmdSec ID="dmd-00000002">}
  puts %{        <mdRef LOCTYPE="URL" MDTYPE="MODS" xlink:type="simple" xlink:href="#{fname}"/>}
  puts %{    </dmdSec>}
end

def emit_amd_sec_open
  puts %{    <amdSec ID="amd-00000001">}
end

def emit_amd_sec_close
  puts "    </amdSec>"
end

def emit_rights_md(fname)
  puts %{        <rightsMD ID="rmd-00000001">}
  puts %{           <mdRef LOCTYPE="URL" MDTYPE="METSRIGHTS" xlink:type="simple" xlink:href="#{fname}"/>}
  puts %{        </rightsMD>}
end

def emit_file_sec_open
  puts "    <fileSec>"
end

def emit_file_sec_close
  puts "    </fileSec>"
end

def emit_file_grp_master_open
  puts %{        <fileGrp ID="fg-master" USE="MASTER" ADMID="dpmd-00000001 dmd-00000002">}
end

def emit_file_grp_dmaker_open
  puts %{        <fileGrp ID="fg-dmaker" USE="DMAKER">}
end

def emit_file(fname)
  match = /(.+)\.tif\z/.match(fname)
  raise "badly formed filename #{fname}" unless match
  id = match[1]
  puts %{            <file ID="f-#{id}" MIMETYPE="image/tiff">}
  puts %{                <FLocat LOCTYPE="URL" xlink:type="simple" xlink:href="#{fname}"/>}
  puts %{            </file>}
end

def emit_files(file_list)
  file_list.each { |f| emit_file(File.basename(f)) }
end

def get_files(dir, pattern, exclude = nil)
  final_list = []

  files = Dir.glob(File.join(dir, pattern))
  files.each do |f|
    unless exclude.nil?
      next if exclude.match(f)
    end
    final_list << File.basename(f)
  end
  final_list.sort!
end

def emit_file_grp_close
  puts %{        </fileGrp>}
end

def emit_struct_map_open
  puts %|    <structMap ID="smd-00000001" TYPE="INTELLECTUAL_ENTITY"> |
end

def emit_struct_map_close
  puts %|    </structMap>|
end

def emit_struct_map_div_open
  puts "      <div>"
end

def emit_struct_map_div_close
  puts "      </div>"
end

def emit_mptr(mptr)
  puts %Q{                <mptr LOCTYPE="URL" xlink:type="simple" xlink:href="#{mptr}"/>}
end

def emit_struct_map_part_divs(parts)
  parts.each_index do |idx|
    p = parts[idx]
    emit_struct_map_inner_div_open({order: idx + 1, orderlabel: p.orderlabel})
    emit_mptr(p.mptr) unless p.mptr.nil?
    emit_struct_map_inner_div_close
  end
end

def emit_struct_map_inner_div_open(h)
  o    = h[:order]
  ol   = h[:orderlabel]
  ostr = %Q{ORDER="#{o}"}
  ostr += %Q{ ORDERLABEL="#{ol}"} unless ol.nil?
  puts %Q{        <div TYPE="INTELLECTUAL_ENTITY" ID="s-ie-#{sprintf("%08d", o)}" DMDID="dmd-00000001 dmd-00000002" ADMID="rmd-00000001" #{ostr}>}
end

def emit_struct_map_inner_div_close
  puts %{        </div>}
end

def emit_struct_map_slot_div(slot_label, order)
  puts "            <div ID=\"s-#{slot_label}\" ORDER=\"#{order}\"> "
  puts "                <fptr FILEID=\"f-#{slot_label}_m\"/> "
  puts "                <fptr FILEID=\"f-#{slot_label}_d\"/> "
  puts "            </div> "
end

def emit_struct_map_slot_divs(slot_list)
  slot_list.each_index do |i|
    emit_struct_map_slot_div(slot_list[i], i + 1)
  end
end

#------------------------------------------------------------------------------
# utility / validation / extraction methods:
#------------------------------------------------------------------------------
def get_required_files(dir)
  inventory = {
    mods:        '_mods.xml',
    marcxml:     '_marcxml.xml',
    metsrights:  '_metsrights.xml'
  }

  fhash  = {}
  errors = []
  inventory.each_pair do |k,f|
    result = Dir.glob(File.join(dir, "*#{f}"))
    if result.length == 1
      fhash[k] = File.basename(result[0])
    else
      errors << "missing or too many files ending in #{f}\n"
    end
  end

  raise errors.to_s unless errors.empty?
  fhash
end

def extract_parts(array)
  array.collect {|p| Part.new(p)}
end

def print_usage
  $stderr.puts "Usage: #{$0} <object id> <path to ie> <part 1> [<part 2>|'UNAVAIL' ...]"
  $stderr.puts "   <object id>   : R* identifier. Will be inserted into METS @OBJID"
  $stderr.puts "   <path to ie>  : path to the directory containing the IE files"
  $stderr.puts "   <part 1>      "
  $stderr.puts "   <part 2...n>  "
  $stderr.puts "   'UNAVAIL'     : this portion of the intellectual entity is not available"
  $stderr.puts "   e.g., "
  $stderr.puts "   ruby #{$0} '6efa1021-7453-4150-8d4a-705899530d8e' /path/to/ie 'nyu_aco000177_mets.xml#s-ie-00000001' 'UNAVAIL' 'nyu_aco000179_mets.xml#s-ie-00000001'"
end

#------------------------------------------------------------------------------
# obj_id     = ARGV[0]
# src_dir    = ARGV[1]
# part_1     = ARGV[2]
# [part_2    = ARGV[3]]
# [part_3    = ARGV[4]]
# ...
# [part_n    = ARGV[n + 1]]
#..............................................................................
def validate_and_extract_args(args_in)

  args_out = {}
  errors   = []

  # argument count correct?
  unless args_in.length >= 3
    $stderr.puts "incorrect number of arguments"
    print_usage
    exit 1
  end

  # assume object identifier present because arg count is correct
  args_out[:obj_id]  = args_in[0]

  # test directory
  candidate = args_in[1]
  if Dir.exists?(candidate)
    args_out[:dir] = candidate
  else
    # CANNOT CONTINUE
    $stderr.puts "directory does not exist: #{candidate}"
    exit 1
  end

  # extract list of parts
  args_out[:parts] = extract_parts(args_in[2..-1])

  begin
    args_out[:required_files] = get_required_files(args_out[:dir])
  rescue Exception => e
    errors << "problem with metadata files: #{e.message}"
  end

  unless errors.empty?
    estr = errors.join("\n")
    $stderr.puts "ERROR:\n #{estr}"
    print_usage
    exit 1
  end

  args_out
end


#------------------------------------------------------------------------------
# MAIN
#------------------------------------------------------------------------------
args = validate_and_extract_args(ARGV)

required_files = args[:required_files]
emit_xml_header
emit_mets_open(args[:obj_id])
emit_template_version
emit_mets_hdr_open
emit_agent({role: "DISSEMINATOR", type: "ORGANIZATION", name: "New York University Libraries"})
emit_agent({role: "CREATOR", type: "INDIVIDUAL", name: "Joseph G. Pawletko"})
emit_alt_record_id({type: "NYU-DL-RSTAR", id: args[:obj_id]})
emit_mets_hdr_close
emit_dmd_marcxml(required_files[:marcxml])
emit_dmd_mods(required_files[:mods])
emit_amd_sec_open
emit_rights_md(required_files[:metsrights])
emit_amd_sec_close
emit_struct_map_open
emit_struct_map_div_open
emit_struct_map_part_divs(args[:parts])
emit_struct_map_div_close
emit_struct_map_close
emit_mets_close

exit 0

=begin
TODO:
emit struct map
add all tests
=end
