
class BuildDeployer

  def initialize(project = nil)
  end

  def build_finished(build)

    output = `cd #{build.project.local_checkout}/script && ./deploy`
    CruiseControl::Log.event("***** #{output}")

  end

  private
  
end

Project.plugin :build_deployer