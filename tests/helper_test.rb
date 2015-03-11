require 'test/unit'
require_relative '../src/helper'

class HelperTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_os
    assert_equal(:macosx, Helper.os)
  end

  def test_recursive_proto_search
    folder = '/Users/squad/git'
    assert(Helper.recursive_proto_search(folder).include?('/Users/squad/git/protobuf-guy/tests/test.proto'))
    folder = '.'
    assert(Helper.recursive_proto_search(folder).include?('./tests/test.proto'))
  end

  def test_convertFilePathToWindows
    path = "/"
    assert_equal("\\", Helper.convertFilePathToWindows(path))
    path = "\\"
    assert_equal("\\", Helper.convertFilePathToWindows(path))
    path = "/root/"
    assert_equal("\\root\\", Helper.convertFilePathToWindows(path))
  end

  def test_convertFilePathToUnix
    path = "/"
    assert_equal("/", Helper.convertFilePathToUnix(path))
    path = "\\"
    assert_equal("/", Helper.convertFilePathToUnix(path))
    path = "\\root\\"
    assert_equal("/root/", Helper.convertFilePathToUnix(path))
  end
end