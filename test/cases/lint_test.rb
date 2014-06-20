require 'minitest_helper'
require 'resque/plugin'
class LintTest < Minitest::Test

  def test_resque_plugin_lint
    begin
      Resque::Plugin.lint(Resque::Plugins::SerialQueues)
    rescue Exception => e
      assert false, "Resque::Plugin.lint raised #{e.inspect}"
    end
    assert true
  end

end
