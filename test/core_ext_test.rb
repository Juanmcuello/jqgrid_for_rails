require File.dirname(__FILE__) + '/test_helper.rb'

class CoreExtTest < Test::Unit::TestCase

  def test_string_to_json_var
    js = 'function() { alert("test"); }'
    assert_equal( js.to_json_var, js)
  end

end 

