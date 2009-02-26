require 'new_relic/config/rails'
require 'new_relic/agent/agent_test_controller'

class NewRelic::Config::Test < NewRelic::Config::Rails
  def env
    'test'
  end
  def app
    :rails
  end
  def config_file
    File.join(File.dirname(__FILE__), "newrelic.yml")
  end
  def initialize local_env
    super local_env
    setup_log 
  end
  # when running tests, don't write out stderr
  def log!(msg, level=:info)
    log.send level, msg if log
  end
  
  # Add the default route in case it's missing.  Need it for testing.
  def install_devmode_route
    super
    ActionController::Routing::RouteSet.class_eval do
      next if defined? draw_without_test_route
      def draw_with_test_route
        draw_without_test_route do | map |
          map.connect ':controller/:action/:id'
          yield map        
        end
      end
      alias_method_chain :draw, :test_route
    end
  end
end