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

      if !File.exists?("Mobile-Security-Framework-MobSF")
        cloneStatus = Process.run("git clone https://github.com/MobSF/Mobile-Security-Framework-MobSF.git", shell: true, input: STDIN, output: STDOUT, error: STDERR)
        raise Exception.new("Error installing MobSF depedencies : Cloning MobSF Repo") unless cloneStatus.success?
      end

      STDOUT.puts "------------------------------------"
      STDOUT.puts "Installing MobSF"
      STDOUT.puts "------------------------------------"

      Dir.cd("Mobile-Security-Framework-MobSF")

      requirementInstallStatus = Process.run("pip install --no-cache-dir --use-deprecated=legacy-resolver -r requirements.txt", shell: true, input: STDIN, output: STDOUT, error: STDERR)
      raise Exception.new("Error installing MobSF depedencies : Installing MobSF Required Python Packages") unless requirementInstallStatus.success?

      setupStatus = Process.run("./setup.sh", shell: true, input: STDIN, output: STDOUT, error: STDERR)
      raise Exception.new("Error installing MobSF depedencies : Running setup script") unless setupStatus.success?

      Dir.cd("../")

      STDOUT.puts "MobSF Framework successfully installed!"
      STDOUT.puts "To start MobSF server, run :./run.sh 127.0.0.1:8000"
    end
  end
end
