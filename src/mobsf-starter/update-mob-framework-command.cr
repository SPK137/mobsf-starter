require "./command-protocol"
require "option_parser"

module MobSFStarter
  class UpdateMobFrameworkCommand
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
      STDOUT.puts "Updating MobSF"
      STDOUT.puts "------------------------------------"

      Dir.cd("Mobile-Security-Framework-MobSF")

      gitPullStatus = Process.run("git pull origin master", shell: true, input: STDIN, output: STDOUT, error: STDERR)
      raise Exception.new("Error installing MobSF depedencies : git pull") unless gitPullStatus.success?

      activateStatus = Process.run(". venv/bin/activate", shell: true, input: STDIN, output: STDOUT, error: STDERR)
      raise Exception.new("Error installing MobSF depedencies : activate venv") unless activateStatus.success?

      pylibInstallStatus = Process.run("pip install --no-cache-dir --use-deprecated=legacy-resolver -r requirements.txt", shell: true, input: STDIN, output: STDOUT, error: STDERR)
      raise Exception.new("Error installing MobSF depedencies : Loading Requirements") unless pylibInstallStatus.success?

      migrateStatus = Process.run("python manage.py makemigrations && python manage.py makemigrations StaticAnalyzer && python manage.py migrate", shell: true, input: STDIN, output: STDOUT, error: STDERR)
      raise Exception.new("Error installing MobSF depedencies : Migrating MobSF") unless migrateStatus.success?

      deactivateStatus = Process.run("deactivate", shell: true, input: STDIN, output: STDOUT, error: STDERR)
      raise Exception.new("Error installing MobSF depedencies : deactivate venv") unless activateStatus.success?

      STDOUT.puts "MobSF Framework successfully installed!"
    end
  end
end
