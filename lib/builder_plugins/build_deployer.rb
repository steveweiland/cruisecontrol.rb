
class BuildDeployer

  def initialize(project = nil)
  end

  def build_finished(build)

    output = `cd #{build.project.local_checkout}/script && ./deploy`

    File.open("/tmp/deploy-out", "r") do |infile|
      while (line = infile.gets)
        CruiseControl::Log.event( line )
      end
    end

  end

  private
  
end

Project.plugin :build_deployer