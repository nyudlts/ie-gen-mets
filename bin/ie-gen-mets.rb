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

#------------------------------------------------------------------------------
# XML emit methods:
#------------------------------------------------------------------------------
def emit_template_version
  puts '<?ie-wip-template version="info:nyu/dl/v1.0/templates/ie/wip/v0.0.1"?>'
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
  puts "    <amdSec>"
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

def emit_struct_map_open(h)
  puts %|    <structMap ID="smd-00000001" TYPE="#{h[:se_type]} BINDING_ORIENTATION:#{h[:binding]} SCAN_ORDER:#{h[:scan_order]} READ_ORDER:#{h[:read_order]}"> |
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

def emit_struct_map_inner_div_open
  puts %{        <div TYPE="INTELLECTUAL_ENTITY" ID="s-ie-00000001" DMDID="dmd-00000001 dmd-00000002" ADMID="rmd-00000001">}
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
def get_md_file_inventory(dir)
  inventory = {
    mods:        '_mods.xml',
    marcxml:     '_marcxml.xml',
    metsrights:  '_metsrights.xml',
    eoc:         '_eoc.csv',
    target:      '_ztarget_m.tif'
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


def print_usage
  $stderr.puts "Usage: #{$0} <object id> <source entity type> " +
    "<binding orientation> <scan order> <read order> " +
    "<path-to-text dir>"
  $stderr.puts "   e.g., "
  $stderr.puts "   ruby #{$0} 'nyu_aco000003' 'SOURCE_ENTITY:TEXT' 'VERTICAL' 'LEFT_TO_RIGHT' 'RIGHT_TO_LEFT'  /content/prod/rstar/content/nyu/aco/wip/se/nyu_aco000003/data > foo_mets.xml"
end

#------------------------------------------------------------------------------
# obj_id     = ARGV[0]
# se_type    = ARGV[1]
# binding    = ARGV[2]
# scan_order = ARGV[3]
# read_order = ARGV[4]
# src_dir    = ARGV[5]
#..............................................................................
def validate_and_extract_args(args_in)
  valid_se_types    = %w(SOURCE_ENTITY:TEXT)
  valid_bindings    = %w(VERTICAL HORIZONTAL)
  valid_scan_orders = %w(LEFT_TO_RIGHT RIGHT_TO_LEFT TOP_TO_BOTTOM BOTTOM_TO_TOP)
  valid_read_orders = %w(LEFT_TO_RIGHT RIGHT_TO_LEFT TOP_TO_BOTTOM BOTTOM_TO_TOP)

  args_out = {}
  errors   = []

  # argument count correct?
  unless args_in.length == 6
    $stderr.puts "incorrect number of arguments"
    print_usage
    exit 1
  end

  # assume object identifier present because arg count is correct
  args_out[:obj_id]  = args_in[0]

  # construct array to validate arguments with controlled vocabularies
  # idx:    index for value in args_in
  # key:    key   for          args_out hash
  # values: controlled vocabulary against which to validate
  # msg:    text for error message
  [{idx: 1, key: :se_type,    values: valid_se_types,    msg: "se type"},
   {idx: 2, key: :binding,    values: valid_bindings,    msg: "binding orientation"},
   {idx: 3, key: :scan_order, values: valid_scan_orders, msg: "scan order"},
   {idx: 4, key: :read_order, values: valid_read_orders, msg: "read order"}].each do |x|

    # extract the candidate value
    candidate = args_in[x[:idx]]

    if x[:values].include?(candidate)
      args_out[x[:key]] = candidate
    else
      errors << "incorrect #{x[:msg]} : #{candidate}"
    end
  end

  # test directory
  candidate = args_in[5]
  if Dir.exists?(candidate)
    args_out[:dir] = candidate
  else
    # CANNOT CONTINUE
    $stderr.puts "directory does not exist: #{candidate}"
    exit 1
  end


  # assemble file lists
  master_files = get_master_files(args_out[:dir])
  dmaker_files = get_dmaker_files(args_out[:dir])
  slot_list    = gen_slot_list(args_out[:dir])
  begin
    assert_master_dmaker_match!(master_files, dmaker_files)
  rescue Exception => e
    errors << "#{e.message}"
  end

  args_out[:master_files] = master_files
  args_out[:dmaker_files] = dmaker_files
  args_out[:slot_list]    = slot_list

  begin
    md_files = get_md_file_inventory(args_in[5])
  rescue Exception => e
    errors << "problem with metadata files: #{e.message}"
  end
  args_out[:md_files] = md_files

  unless errors.empty?
    estr = errors.join("\n")
    $stderr.puts "ERROR:\n #{estr}"
    print_usage
    exit 1
  end

  args_out
end


def get_master_files(dir)
  get_files(dir, '*_m.tif', /.+_ztarget_m.tif/)
end

def get_dmaker_files(dir)
  get_files(dir, '*_d.tif')
end

def gen_slot_list(dir)
  # d files map one-to-one to the pages in the text
  slots = get_files(dir, '*_d.tif')
  slots.collect {|s| s.sub(/_d.tif\z/,'')}
end

def assert_master_dmaker_match!(m, d)
  raise "mismatch in master / dmaker file count" unless m.length == d.length
  errors = []
  m.each_index do |i|
    m_base = m[i].sub(/_m.tif\z/,'')
    d_base = d[i].sub(/_d.tif\z/,'')
    errors << "prefix mismatch: #{m[i]} #{d[i]}" unless m_base == d_base
  end
  unless errors.empty?
    estr = errors.join("\n")
    raise "mismatches in master / dmaker files:\n #{estr}"
  end
end


#------------------------------------------------------------------------------
# MAIN
#------------------------------------------------------------------------------
args = validate_and_extract_args(ARGV)

md_files = args[:md_files]
emit_xml_header
emit_mets_open(args[:obj_id])
emit_template_version
emit_mets_hdr
emit_dmd_marcxml(md_files[:marcxml])
emit_dmd_mods(md_files[:mods])
emit_amd_sec_open
emit_rights_md(md_files[:metsrights])
emit_digiprov_target(md_files[:target])
emit_digiprov_eoc(md_files[:eoc])
emit_amd_sec_close
emit_file_sec_open
emit_file_grp_master_open
emit_files(args[:master_files])
emit_file_grp_close
emit_file_grp_dmaker_open
emit_files(args[:dmaker_files])
emit_file_grp_close
emit_file_sec_close
emit_struct_map_open(args)
emit_struct_map_div_open
emit_struct_map_inner_div_open
emit_struct_map_slot_divs(args[:slot_list])
emit_struct_map_inner_div_close
emit_struct_map_div_close
emit_struct_map_close
emit_mets_close

exit 0
