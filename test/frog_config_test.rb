
require 'test_helper'

class FrogConfigTest < Minitest::Test

  def test_that_dirs_are_scanned_correctly
    FrogConfig.create_and_populate_frog_files(["./test"])
    data = FrogConfig.read_todo_file("frog_test")
    assert_match data['TODO'][0], 'This was added by test'
  end

end

