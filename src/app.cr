require "option_parser"
require "file_utils"
require "./mobsf-starter"

# TODO: Write documentation for `MobSFStarter`
module MobSFStarter
  VERSION = "0.7.0"

  SETUP_BANNER = "Usage: mobsf setup [ -t --setup-type ] [ -h ] [ -v ]"

  module InstallType
    STATIC_ONLY  = "static"
    WITH_DYNAMIC = "all"
  end

  getter install_mob_static_dep_cmd
  getter install_mob_dynamic_dep_cmd
  getter install_mob_framework_cmd
  getter update_mob_framework_cmd
  getter stdout
  getter stderr

  class App
    def initialize(cmd = "yarn", @stdin : IO = STDIN, @stdout : IO = STDOUT, @stderr : IO = STDERR, next_opts = [] of String)
      @install_mob_static_dep_cmd = InstallMobStaticDepCommand.new(cmd, next_opts, input: @stdin, output: @stdout, error: @stderr)
      @install_mob_dynamic_dep_cmd = InstallMobDynamicDepCommand.new(cmd, next_opts, input: @stdin, output: @stdout, error: @stderr)
      @install_mob_framework_cmd = InstallMobFrameworkCommand.new(cmd, next_opts, input: @stdin, output: @stdout, error: @stderr)
      @update_mob_framework_cmd = UpdateMobFrameworkCommand.new(cmd, next_opts, input: @stdin, output: @stdout, error: @stderr)
    end

    def start
      setup = false
      update = false
      dry_run = false
      setup_type = ""

      opts = OptionParser.new do |opts|
        opts.banner = "MobSF Installer App"

        opts.on "", "" do
          @stdout.puts opts
          exit
        end

        opts.on "-v", "--version", "Show version" do
          @stdout.puts VERSION
          exit
        end

        opts.on "-h", "--help", "Show help" do
          @stdout.puts opts
          exit
        end

        opts.on "setup", %[Setup type to perform [ static, all ] \n- Run "mobsf setup --setup-type=static" : install dependencies for static analysis\n- Run "mobsf setup --setup-type=all" : install dependencies for both static and dynamic analysis] do
          setup = true
          opts.banner = SETUP_BANNER

          opts.on "-t SETUP_TYPE", "--setup-type=SETUP_TYPE", %[Setup type to perform [ static, all ] \n- Run "mobsf setup --setup-type=static" : install dependencies for static analysis\n- Run "mobsf setup --setup-type=all" : install dependencies for both static and dynamic analysis] do |_setup_type|
            if _setup_type != InstallType::STATIC_ONLY && _setup_type != InstallType::WITH_DYNAMIC
              @stderr.puts "Invalid setup type: #{_setup_type}: [ static, all ]"
              exit 1
            end

            setup_type = _setup_type
          end
        end

        opts.on "update", "Update MobSF" do
          update = true
        end

        opts.missing_option do |option_flag|
          if option_flag == "-t" || option_flag == "--setup-type"
            @stderr.puts "ERROR: #{option_flag} is missing the setup type."
          else
            @stderr.puts "ERROR: #{option_flag} is missing something."
          end
          @stderr.puts ""
          @stderr.puts opts
          exit(1)
        end

        opts.invalid_option do |flag|
          @stderr.puts "ERROR: #{flag} is not a valid option."
          @stderr.puts opts
          exit(1)
        end
      end

      begin
        opts.parse

        if setup
          if setup_type != InstallType::STATIC_ONLY && setup_type != InstallType::WITH_DYNAMIC
            @stdout.printf "Please choose setup type [ static, all ] : "
            setup_type = @stdin.gets
            if setup_type != InstallType::STATIC_ONLY && setup_type != InstallType::WITH_DYNAMIC
              @stdout.puts "Please choose correct setup type."
              exit 1
            end
          end

          @stdout.puts %[======================================\n     Scandina Extension for MobSF     \n======================================]
          setup_mobsf(setup_type)

          @stdout.puts "Done setting up MobSF! "
        else
          if update
            update_mobsf()
            @stdout.puts "Done updating MobSF!"
          else
            @stdout.puts opts
          end
        end
      rescue ex
        puts "ERROR: #{ex.message}"
        puts opts
        exit(1)
      end
    end

    private def setup_mobsf(setup_type)
      @install_mob_static_dep_cmd.call(ARGV)

      if setup_type == InstallType::WITH_DYNAMIC
        @install_mob_dynamic_dep_cmd.call(ARGV)
      end

      @install_mob_framework_cmd.call(ARGV)

      update_mobsf()

      STDOUT.puts %[To run MobSF, navigate to Mobile-Security-Framework-MobSF folder and run "./run.sh"]

      if setup_type == InstallType::WITH_DYNAMIC
        STDOUT.puts %[To run dynamic analysis, run "emulator @MobSF_Android -writable-system -no-snapshot" to start emulator before starting the dynamic analysis]
      end

      if setup_type == ""
        Dir.cd("../")
      end
    end

    private def update_mobsf
      @update_mob_framework_cmd.call(ARGV)
    end
  end
end
