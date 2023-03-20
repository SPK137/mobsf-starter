require "./command-protocol"
require "option_parser"

module MobSFStarter
  class InstallMobFrameworkCommand
    include CommandProtocol

    getter cmd
    getter opts
    getter stdin
    getter stdout
    getter stderr

    def initialize(@cmd : String, opts = Array(String).new, @input : IO = STDIN, @output : IO = STDOUT, @error : IO = STDERR)
      @opts = Array(String).new
    end

    def call(args : Array(String))
      STDOUT.puts "------------------------------------"
      STDOUT.puts "Cloning MobSF Repo..."
      STDOUT.puts "------------------------------------"

      cloneStatus = Process.run("git clone https://github.com/MobSF/Mobile-Security-Framework-MobSF.git", shell: true, input: STDIN, output: STDOUT, error: STDERR)
      raise Exception.new("Error installing MobSF depedencies : Cloning MobSF Repo") unless cloneStatus.success?

      STDOUT.puts "------------------------------------"
      STDOUT.puts "Installing MobSF"
      STDOUT.puts "------------------------------------"

      Dir.cd("Mobile-Security-Framework-MobSF")
      
      WsetupStatus = Process.run("./setup.sh", shell: true, input: STDIN, output: STDOUT, error: STDERR)
      raise Exception.new("Error installing MobSF depedencies : Running setup script") unless setupStatus.success?

      Dir.cd("../")

      STDOUT.puts "MobSF Framework successfully installed!"
    end
  end
end
