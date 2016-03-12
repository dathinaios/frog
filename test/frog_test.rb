require 'test_helper'

# override yes for testing user input
module Frog
  class Interface
    private
    def yes?(whatever)
      return true
    end
  end
end

class FrogTest < Minitest::Test

  def setup
    capture_io{Frog::Interface.start(['switch', 'frog_test'])}.join ''
    @data = FrogConfig.read_todo_file('frog_test')
  end

  def test_that_it_has_a_version_number
    refute_nil ::Frog::VERSION
  end

  def test_add
    out = capture_io{Frog::Interface.start(['add', 'this was added by test'])}.join ''
    assert_match /Added succesfully to:/, out
    assert_match @data['TODO'].last, 'This was added by test'
  end

  def test_remove
    last_addition_index = @data['TODO'].count - 1
    out = capture_io{Frog::Interface.start(['remove', last_addition_index])}.join ''
    assert_match /'This was added by test' has been removed/, out
  end

  # any_instance_of(Frog::Interface) do |cli|
  #   mock(cli).yes?(anything){ true }
  # end

end

