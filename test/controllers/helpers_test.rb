require 'test/test_helper' 

class MockController < ApplicationController
end

class ControllerHelpersTest < ActionController::TestCase

  def setup
    @controller = MockController.new
  end

  tests MockController

  test "order_by_from with sidx and sord" do
    params = {'sidx' => 'updated_at', 'sord' => 'desc' }
    assert_equal 'updated_at desc', @controller.order_by_from_params(params)
  end

  test "order_by_from with sidx" do
    params = {'sidx' => 'updated_at'}
    assert_equal 'updated_at', @controller.order_by_from_params(params)
  end

  test "order_by_from without sidx" do
    params = {'sord' => 'desc' }
    assert_nil @controller.order_by_from_params(params)
  end

end
