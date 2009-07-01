#
# todo: put a doc here
# todo: a test
# todo: fix smell of report
# todo: add dep for tinder
#

require "tinder"

class CampfireNotifier

  attr_accessor :account
  attr_accessor :use_ssl
  attr_accessor :room
  attr_accessor :user
  attr_accessor :pass

  def initialize(project = nil)
    @account = Configuration.campfire_notifier_account
    @use_ssl = Configuration.campfire_notifier_use_ssl
    @room = ''
    @user = Configuration.campfire_notifier_user
    @pass = Configuration.campfire_notifier_pass
  end
  
  def build_finished(build)
    return if not build.failed? or @account.empty? or @room.empty? or @user.empty? or @pass.empty?
    say! build, "#{build.project.name} build #{build.label} failed", "The build failed."
  end

  def build_fixed(build, previous_build)
    return if @account.empty? or @room.empty? or @user.empty? or @pass.empty?
    say! build, "#{build.project.name} build #{build.label} fixed", "The build has been fixed."
  end

  private

  def say!( build, subject, message )
    begin
      msg = "[CruiseControl] #{subject}, #{build.url}"
      buf = report build, subject, message
      the_room.speak msg
      the_room.paste buf
      the_room.leave
      CruiseControl::Log.event( "Said #{msg} on campfire", :debug )
    rescue => e
      CruiseControl::Log.event( "Error writting to campfire #{e.message}", :error )
    end
  end

  def the_room
    @the_room ||= begin
      opts = {}
      opts[:ssl] = @use_ssl ? true : false
      campfire = Tinder::Campfire.new(@account, opts)
      campfire.login(@user, @pass)
      campfire.find_room_by_name(@room)
    end
  end

  ## baaah
  def report( build, subject, message )
    failures_and_errors = BuildLogParser.new(build.output).failures_and_errors.map { |e| formatted_error(e) }
    buf = ''
    if Configuration.dashboard_url
      buf << "#{message}\n"
      buf << "\n"
      buf << "CHANGES\n"
      buf << "-------\n"
      buf << "#{build.changeset}\n"
      buf << "\n"
      unless failures_and_errors.empty?
        buf << "TEST FAILURES AND ERRORS\n"
        buf << "-----------------------\n"
        buf << "#{failures_and_errors}\n"
        buf << "\n"
      end
      buf << "See #{build.url} for details.\n"
    else
      buf << "#{message}\n"
      buf << "\n"
      buf << "  Note: if you set Configuration.dashboard_url in config/site_config.rb, you'd see a link to the build page here.\n"
      buf << "\n"
      buf << "#CHANGES\n"
      buf << "#-------\n"
      buf << "#{build.changeset}\n"
      buf << "\n"
      buf << "#BUILD LOG\n"
      buf << "#---------\n"
      buf << "#{build.output}\n"
      buf << "\n"
      buf << "#PROJECT SETTINGS\n"
      buf << "#----------------\n"
      buf << "#{build.project_settings}\n"
    end
    buf
  end

  def formatted_error(error)
    return "Name: #{error.test_name}\n" +
           "Type: #{error.type}\n" +
           "Message: #{error.message}\n\n" +
           error.stacktrace + "\n\n\n"
  end

end

Project.plugin :campfire_notifier
