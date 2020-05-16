require 'test_helper'

class RenderingControllerTest < ActionDispatch::IntegrationTest
  def setup
    Rails.application.config.turbolinks_render.render_with_turbolinks_by_default = true
  end

  %i[put patch post].each do |http_verb|
    test "Render with turbolinks by default for #{http_verb} requests" do
      send http_verb, update_with_turbolinks_tasks_url, xhr: true
      assert_js_function_in_response
    end

    test "JSON responses are not handlded by Turbolinks for #{http_verb} requests" do
      send http_verb, update_with_json_response_tasks_url, xhr: true
      assert_equal 'application/json', response.content_type
      assert_equal 'ok', JSON.parse(response.body)['result']
    end

    test "Turbolinks rendering can be disabled with `turbolinks: false` for #{http_verb} requests" do
      send http_verb, update_without_turbolinks_tasks_url, xhr: true
      assert_select 'p', text: 'Without turbolinks!'
      assert_equal 'text/html', @response.content_type
    end

    test "Turbolinks can be disabled by default for #{http_verb} requests" do
      Rails.application.config.turbolinks_render.render_with_turbolinks_by_default = false
      send http_verb, update_with_turbolinks_tasks_url, xhr: true
      assert_no_match(/function/, response.body)
      assert_equal 'text/html', @response.content_type
    end

    test "Turbolinks can be enabled on a per request basis for #{http_verb} requests" do
      Rails.application.config.turbolinks_render.render_with_turbolinks_by_default = false
      send http_verb, update_with_turbolinks_forcing_it_tasks_url, xhr: true
      assert_js_function_in_response
    end

    test "Turbolinks can be ignored for specific paths and their subpaths for #{http_verb} requests" do
      Rails.application.config.turbolinks_render.render_with_turbolinks_by_default = true
      Rails.application.config.turbolinks_render.ignored_paths = ['/tasks/update_ignored']
      send http_verb, update_ignored_tasks_url, xhr: true
      assert_no_match(/function/, response.body)
      assert_equal 'text/html', @response.content_type
      send http_verb, update_ignored_subpath_tasks_url, xhr: true
      assert_no_match(/function/, response.body)
      assert_equal 'text/html', @response.content_type
    end
  end

  def assert_js_function_in_response
    assert_match(/function/, response.body)
    assert_equal 'text/javascript', response.content_type
  end
end
