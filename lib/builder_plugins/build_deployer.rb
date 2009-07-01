
class BuildDeployer

  def initialize(project = nil)
  end

  def build_finished(build)

    output = `cd #{build.project.local_checkout}/script && ./deploy`
    CruiseControl::Log.event("***** #{output}")  # output is always empty... Why?

  end

  private
  
end

Project.plugin :build_deployer