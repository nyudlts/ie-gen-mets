require 'test/unit'
require 'open3'

class TestIeGenMets < Test::Unit::TestCase

  COMMAND  = 'ruby bin/ie-gen-mets.rb'
  VALID_IE = 'test/ies/valid'
  EMPTY_IE = 'test/ies/empty-dir'
  CANONICAL_XML  = 'test/canonical/valid_mets.xml'
  MPTR_1  = 'nyu_aco000177_mets.xml#s-ie-00000001'
  MPTR_2  = 'nyu_aco000178_mets.xml#s-ie-00000001'
  MISSING = 'MISSING'
  MPTR_4  = 'nyu_aco000180_mets.xml#s-ie-00000001'

  def test_exit_status_with_valid_text
    o, e, s = Open3.capture3("#{COMMAND} '6efa1021-7453-4150-8d4a-705899530d8e' #{VALID_IE} #{MPTR_1} #{MPTR_2} #{MISSING} #{MPTR_4}")
    assert(s == 0, "incorrect exit status")
    assert_match(/<mets xmlns/, o, "no mets output detected")
  end

=begin
  def test_with_incorrect_argument_count
    o, e, s = Open3.capture3("#{COMMAND}")
    assert(s != 0, "incorrect argument count")
    assert(o == '')
    assert_match(/incorrect number of arguments/, e, 'unexpected error message')
  end

  def test_with_invalid_dir
    o, e, s = Open3.capture3("#{COMMAND} '6efa1021-7453-4150-8d4a-705899530d8e' 'SOURCE_ENTITY:TEXT' 'VERTICAL' 'LEFT_TO_RIGHT' 'RIGHT_TO_LEFT' invalid-dir-path")
    assert(s != 0, "incorrect exit status")
    assert(o == '')
    assert_match(/directory does not exist/, e, 'unexpected error message')
  end

  def test_invalid_se_type
    o, e, s = Open3.capture3("#{COMMAND} '6efa1021-7453-4150-8d4a-705899530d8e' 'INVALID' 'VERTICAL' 'LEFT_TO_RIGHT' 'RIGHT_TO_LEFT' #{VALID_IE}")
    assert(s != 0)
    assert(o == '')
    assert_match(/incorrect se type/, e, 'unexpected error message')
  end

  def test_invalid_binding_orientation
    o, e, s = Open3.capture3("#{COMMAND} '6efa1021-7453-4150-8d4a-705899530d8e' 'SOURCE_ENTITY:TEXT' 'INVALID' 'LEFT_TO_RIGHT' 'RIGHT_TO_LEFT' #{VALID_IE}")
    assert(s != 0)
    assert(o == '')
    assert_match(/incorrect binding orientation/, e, 'unexpected error message')
  end

  def test_invalid_scan_order
    o, e, s = Open3.capture3("#{COMMAND} '6efa1021-7453-4150-8d4a-705899530d8e' 'SOURCE_ENTITY:TEXT' 'HORIZONTAL' 'INVALID' 'RIGHT_TO_LEFT' #{VALID_IE}")
    assert(s != 0)
    assert(o == '')
    assert_match(/incorrect scan order/, e, 'unexpected error message')
  end

  def test_invalid_read_order
    o, e, s = Open3.capture3("#{COMMAND} '6efa1021-7453-4150-8d4a-705899530d8e' 'SOURCE_ENTITY:TEXT' 'HORIZONTAL' 'RIGHT_TO_LEFT' 'INVALID' #{VALID_IE}")
    assert(s != 0)
    assert(o == '')
    assert_match(/incorrect read order/, e, 'unexpected error message')
  end

  def test_missing_md_files
    o, e, s = Open3.capture3("#{COMMAND} '6efa1021-7453-4150-8d4a-705899530d8e' 'SOURCE_ENTITY:TEXT' 'HORIZONTAL' 'RIGHT_TO_LEFT' 'LEFT_TO_RIGHT' #{EMPTY_IE}")
    assert(s != 0)
    assert(o == '')
    assert_match(/missing or too many files ending in _mods\.xml/, e)
    assert_match(/missing or too many files ending in _marcxml\.xml/, e)
    assert_match(/missing or too many files ending in _metsrights\.xml/, e)
    assert_match(/missing or too many files ending in _eoc\.csv/, e)
    assert_match(/missing or too many files ending in _ztarget_m\.tif/, e)
  end

  def test_mismatched_master_dmaker_file_count
    o, e, s = Open3.capture3("#{COMMAND} '6efa1021-7453-4150-8d4a-705899530d8e' 'SOURCE_ENTITY:TEXT' 'HORIZONTAL' 'RIGHT_TO_LEFT' 'LEFT_TO_RIGHT' #{BAD_M_D_COUNT_IE}")
    assert(s != 0)
    assert(o == '')
    assert_match(/mismatch in master \/ dmaker file count/, e)
  end

  def test_mismatched_master_dmaker_file_prefixes
    o, e, s = Open3.capture3("#{COMMAND} '6efa1021-7453-4150-8d4a-705899530d8e' 'SOURCE_ENTITY:TEXT' 'HORIZONTAL' 'RIGHT_TO_LEFT' 'LEFT_TO_RIGHT' #{BAD_M_D_COUNT_IE}")
    assert(s != 0)
    assert(o == '')
    assert_match(/mismatch in master \/ dmaker file count/, e)
  end

  def test_mismatched_master_dmaker_file_prefixes
    o, e, s = Open3.capture3("#{COMMAND} '6efa1021-7453-4150-8d4a-705899530d8e' 'SOURCE_ENTITY:TEXT' 'HORIZONTAL' 'RIGHT_TO_LEFT' 'LEFT_TO_RIGHT' #{BAD_M_D_PREFIX_IE}")
    assert(s != 0)
    assert(o == '')
    assert_match(/prefix mismatch:/, e)
  end

  def test_output_with_valid_text
    new_xml, e, s = Open3.capture3("#{COMMAND} '6efa1021-7453-4150-8d4a-705899530d8e' 'SOURCE_ENTITY:TEXT' 'VERTICAL' 'LEFT_TO_RIGHT' 'RIGHT_TO_LEFT' #{VALID_IE}")
    assert(s == 0)
    old_xml, e, s = Open3.capture3("cat #{CANONICAL_XML}")
    new_xml_a = new_xml.split("\n")
    old_xml_a = old_xml.split("\n")

    new_xml_a.each_index do |i|
      new = new_xml_a[i].strip
      old = old_xml_a[i].strip

      # replace dates
      if /metsHdr/.match(new)
        timestamp_regex = /[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z/
        new.gsub!(timestamp_regex,'')
        old.gsub!(timestamp_regex,'')
      end
      assert(new == old, "xml mismatch: #{new} #{old}")
    end
  end
=end
end
