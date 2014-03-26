require 'test/unit'
require 'open3'

class TestIeGenMets < Test::Unit::TestCase

  COMMAND  = 'ruby bin/ie-gen-mets.rb'
  VALID_IE_PATH = 'test/ies/valid'
  EMPTY_IE_PATH = 'test/ies/empty-dir'
  CANONICAL_XML  = 'test/canonical/valid_mets.xml'
  MPTR_1  = 'nyu_aco000177_mets.xml#s-ie-00000001'
  MPTR_2  = 'nyu_aco000178_mets.xml#s-ie-00000001'
  UNAVAIL = 'UNAVAIL'
  MPTR_4  = 'nyu_aco000180_mets.xml#s-ie-00000001'

  def test_exit_status_with_valid_text
    o, e, s = Open3.capture3("#{COMMAND} '6efa1021-7453-4150-8d4a-705899530d8e' #{VALID_IE_PATH} #{MPTR_1} #{MPTR_2} #{UNAVAIL} #{MPTR_4}")
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
    o, e, s = Open3.capture3("#{COMMAND} '6efa1021-7453-4150-8d4a-705899530d8e' invalid-dir-path #{MPTR_1}")
    assert(s != 0, "incorrect exit status")
    assert(o == '')
    assert_match(/directory does not exist/, e, 'unexpected error message')
  end

  def test_missing_md_files
    o, e, s = Open3.capture3("#{COMMAND} '6efa1021-7453-4150-8d4a-705899530d8e' #{EMPTY_IE_PATH} #{MPTR_1}")
    assert(s != 0)
    assert(o == '')
    assert_match(/missing or too many files ending in _mods\.xml/, e)
    assert_match(/missing or too many files ending in _marcxml\.xml/, e)
    assert_match(/missing or too many files ending in _metsrights\.xml/, e)
  end

  def test_output_with_valid_text
    new_xml, e, s = Open3.capture3("#{COMMAND} '6efa1021-7453-4150-8d4a-705899530d8e' #{VALID_IE_PATH} #{MPTR_1} #{MPTR_2} #{UNAVAIL} #{MPTR_4}")
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
end
