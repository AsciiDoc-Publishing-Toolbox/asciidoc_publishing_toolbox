require 'minitest/autorun'
require 'asciidoc-publishing-toolbox'

class HelloWorldTest < Minitest::Test
  def test_hi
    assert_equal 'hello world', HelloWorld.hi
  end
end