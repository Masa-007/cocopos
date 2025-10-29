# frozen_string_literal: true

require 'test_helper'

class FlowersControllerTest < ActionDispatch::IntegrationTest
  test 'should get create' do
    get flowers_create_url
    assert_response :success
  end

  test 'should get destroy' do
    get flowers_destroy_url
    assert_response :success
  end
end
