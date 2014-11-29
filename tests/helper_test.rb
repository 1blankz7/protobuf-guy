require 'test/unit'
require '../src/helper'

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
    assert_equal(['/Users/squad/git/protobuf-guy/tests/test.proto'], Helper.recursive_proto_search(folder))
    folder = '.'
    assert_equal(['./test.proto'], Helper.recursive_proto_search(folder))
  end
end