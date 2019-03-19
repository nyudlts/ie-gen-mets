require 'test_helper'
require 'open3'

class TestIeGenMets < MiniTest::Unit::TestCase

  COMMAND  = 'ruby bin/ie-gen-mets.rb'
  VALID_IE_PATH = 'test/fixtures/ies/valid'
  EMPTY_IE_PATH = 'test/fixtures/ies/empty-dir'
  CANONICAL_XML  = 'test/fixtures/canonical/valid_mets.xml'
  PART_1  = 'nyu_aco000177_mets.xml#s-ie-00000001:V1'
  PART_2  = 'nyu_aco000178_mets.xml#s-ie-00000001:V2'
  UNAVAIL = 'UNAVAIL:V3'
  PART_4  = 'nyu_aco000180_mets.xml#s-ie-00000001:V4'

  CANONICAL_COMPLEX_LABEL_XML  = 'test/fixtures/canonical/valid_mets_complex_label.xml'
  COMPLEX_PART_1  = 'nyu_aco000177_mets.xml#s-ie-00000001:V1:pt. 2'
  COMPLEX_PART_2  = 'nyu_aco000178_mets.xml#s-ie-00000001:V2|strudel'
  COMPLEX_UNAVAIL = 'UNAVAIL:V3!bar'
  COMPLEX_PART_4  = 'nyu_aco000180_mets.xml#s-ie-00000001:V4&5'


  def test_exit_status_with_valid_ie
    o, e, s = Open3.capture3("#{COMMAND} '6efa1021-7453-4150-8d4a-705899530d8e' #{VALID_IE_PATH} #{PART_1} #{PART_2} #{UNAVAIL} #{PART_4}")
    assert(s == 0, "incorrect exit status")
    assert_match(/<mets xmlns/, o, "no mets output detected")
  end

  def test_with_incorrect_argument_count
    o, e, s = Open3.capture3("#{COMMAND}")
    assert(s != 0, "incorrect argument count")
    assert(o == '')
    assert_match(/incorrect number of arguments/, e, 'unexpected error message')
  end

  def test_with_invalid_dir
    o, e, s = Open3.capture3("#{COMMAND} '6efa1021-7453-4150-8d4a-705899530d8e' invalid-dir-path #{PART_1}")
    assert(s != 0, "incorrect exit status")
    assert(o == '')
    assert_match(/directory does not exist/, e, 'unexpected error message')
  end

  def test_missing_md_files
    o, e, s = Open3.capture3("#{COMMAND} '6efa1021-7453-4150-8d4a-705899530d8e' #{EMPTY_IE_PATH} #{PART_1}")
    assert(s != 0)
    assert(o == '')
    assert_match(/missing or too many files ending in _mods\.xml/, e)
    assert_match(/missing or too many files ending in _marcxml\.xml/, e)
    assert_match(/missing or too many files ending in _metsrights\.xml/, e)
  end

  def test_output_with_valid_ie
    new_xml, e, s = Open3.capture3("#{COMMAND} '6efa1021-7453-4150-8d4a-705899530d8e' #{VALID_IE_PATH} #{PART_1} #{PART_2} #{UNAVAIL} #{PART_4}")
    assert(s == 0)
    old_xml, e, s = Open3.capture3("cat #{CANONICAL_XML}")
    new_xml_a = new_xml.split("\n")
    old_xml_a = old_xml.split("\n")

    new_xml_a.each_index do |i|
      new = new_xml_a[i].strip
      old = old_xml_a[i].strip

      # strip date-time stamps b/c canonical will have different timestamp than
      # current test pass
      if /metsHdr/.match(new)
        timestamp_regex = /[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z/
        new.gsub!(timestamp_regex,'')
        old.gsub!(timestamp_regex,'')
      end
      assert(new == old, "xml mismatch: #{new} #{old}")
    end
  end

  def test_output_with_valid_ie_with_complex_labels
    new_xml, e, s = Open3.capture3("#{COMMAND} '6efa1021-7453-4150-8d4a-705899530d8e' '#{VALID_IE_PATH}' '#{COMPLEX_PART_1}' '#{COMPLEX_PART_2}' '#{COMPLEX_UNAVAIL}' '#{COMPLEX_PART_4}'")
    assert(s == 0, "Error creating xml. #{e}")
    old_xml, e, s = Open3.capture3("cat #{CANONICAL_COMPLEX_LABEL_XML}")
    new_xml_a = new_xml.split("\n")
    old_xml_a = old_xml.split("\n")

    new_xml_a.each_index do |i|
      new = new_xml_a[i].strip
      old = old_xml_a[i].strip

      # strip date-time stamps b/c canonical will have different timestamp than
      # current test pass
      if /metsHdr/.match(new)
        timestamp_regex = /[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z/
        new.gsub!(timestamp_regex,'')
        old.gsub!(timestamp_regex,'')
      end
      assert(new == old, "xml mismatch: #{new} #{old}")
    end
  end
end
