# frozen_string_literal: true

require 'test_helper'

class AiControllerTest < ActionDispatch::IntegrationTest
  test 'should get generate_text' do
    get ai_generate_text_url
    assert_response :success
  end
end
