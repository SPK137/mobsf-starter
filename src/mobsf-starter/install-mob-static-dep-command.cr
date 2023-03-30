require "./command-protocol"
require "option_parser"

module MobSFStarter
  class InstallMobStaticDepCommand
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
      STDOUT.puts "Updating Package List..."
      STDOUT.puts "------------------------------------"

      updateStatus = Process.run("sudo apt-get update", shell: true, input: STDIN, output: STDOUT, error: STDERR)
      raise Exception.new("Error installing MobSF depedencies : Update") unless updateStatus.success?

      STDOUT.puts "------------------------------------"
      STDOUT.puts "Installing Git..."
      STDOUT.puts "------------------------------------"

      gitStatus = Process.run("sudo apt-get install git", shell: true, input: STDIN, output: STDOUT, error: STDERR)
      raise Exception.new("Error installing MobSF depedencies : Git") unless gitStatus.success?

      STDOUT.puts "------------------------------------"
      STDOUT.puts "Installing Python 3..."
      STDOUT.puts "------------------------------------"

      pythonStatus = Process.run("sudo apt-get install python3 python-is-python3", shell: true, input: STDIN, output: STDOUT, error: STDERR)
      raise Exception.new("Error installing MobSF depedencies : Python 3") unless pythonStatus.success?

      STDOUT.puts "------------------------------------"
      STDOUT.puts "Installing JDK 8..."
      STDOUT.puts "------------------------------------"

      jdkStatus = Process.run("sudo apt-get install openjdk-8-jdk", shell: true, input: STDIN, output: STDOUT, error: STDERR)
      raise Exception.new("Error installing MobSF depedencies : JDK 8") unless jdkStatus.success?

      STDOUT.puts "------------------------------------"
      STDOUT.puts "Installing Other Libraries..."
      STDOUT.puts "------------------------------------"

      otherDepStatus = Process.run("sudo apt install python3-dev python3-venv python3-pip build-essential libffi-dev libssl-dev libxml2-dev libxslt1-dev libjpeg8-dev zlib1g-dev wkhtmltopdf ", shell: true, input: STDIN, output: STDOUT, error: STDERR)
      raise Exception.new("Error installing MobSF depedencies : Other dependencies") unless otherDepStatus.success?

      STDOUT.puts "Dependencies for MobSF's Static Analysis installed!"
    end
  end
end
