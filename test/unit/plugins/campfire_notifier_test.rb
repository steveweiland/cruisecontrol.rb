require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class CampfireNotifierTest < Test::Unit::TestCase
  include FileSandbox

  BUILD_LOG = <<-EOL
    blah blah blah
    something built
    tests passed / failed / etc
  EOL

  def setup
    setup_sandbox

    Configuration.dashboard_url = 'http://foo.baz.com'
    @project = Project.new("myproj")
    @project.path = @sandbox.root
    @build = Build.new(@project, 5)
    @previous_build = Build.new(@project, 4)

    @notifier = CampfireNotifier.new

    @notifier.account = 'foo.baz.com'
    @notifier.use_ssl = false
    @notifier.room = 'test room'
    @notifier.user = 'test_user'
    @notifier.pass = 'test_pass'

    @notifier.the_room = stub( :speak => nil, :paste => nil, :leave => nil )

    @project.add_plugin(@notifier)
  end

  def teardown
    teardown_sandbox
  end

  def test_do_nothing_with_passing_build
    @notifier.the_room.expects(:speak).never
    @notifier.the_room.expects(:paste).never
    @notifier.the_room.expects(:leave).never
    @notifier.build_finished(@build)
  end

  def test_say_something_with_failing_build
    @notifier.the_room.expects(:speak).once
    @notifier.the_room.expects(:paste).once
    @notifier.the_room.expects(:leave).once
    @notifier.build_finished(failing_build)
  end

  def test_say_something_with_fixed_build
    @notifier.the_room.expects(:speak).once
    @notifier.the_room.expects(:paste).once
    @notifier.the_room.expects(:leave).once
    @notifier.build_fixed(@build, @previous_build)
  end

  private

  def failing_build
    @build.stubs(:failed?).returns(true)
    @build.stubs(:output).returns(BUILD_LOG)
    @build
  end
end
