
class BuildDeployer

  def initialize(project = nil)
  end

  def build_finished(build)

    system ("cd #{build.project.local_checkout}/script && ./deploy")

    File.open("/tmp/deploy-out", "r") do |infile|
      CruiseControl::Log.event( "**** Capistrano Deployment Output Begin ****")
      while (line = infile.gets)
        CruiseControl::Log.event( line.chomp )
      end
      CruiseControl::Log.event( "**** Capistrano Deployment Output End ****")
    end

  end

  private
  
end

Project.plugin :build_deployer