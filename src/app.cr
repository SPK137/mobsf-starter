require "option_parser"
require "file_utils"
require "./mobsf-starter"

# TODO: Write documentation for `MobSFStarter`
module MobSFStarter
  VERSION = "0.7.0"

  CREATE_BANNER = "Usage: mobsf install [ -t --install_type ] [ -d ] [ -h ] [ -v ]"

  module InstallType
    STATIC  = "static"
    DYNAMIC = "dynamic"
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

        opts.on "-v", "--version", "Show version" do
          @stdout.puts VERSION
          exit
        end

        opts.on "-h", "--help", "Show help" do
          @stdout.puts opts
          exit
        end

        opts.on "setup", "Setup MobSF" do
          setup = true
          opts.banner = CREATE_BANNER

          opts.on "-d", "--dry-run", "Create only empty dir" do
            dry_run = true
          end

          opts.on "-t SETUP_TYPE", "--setup-type=SETUP_TYPE", "Setup type to perform [ static, dynamic ]. Will setup dependencies for basic MobSF Framework if omitted" do |_setup_type|
            if _setup_type != InstallType::STATIC
              @stderr.puts "Invalid setup type: #{_setup_type}: [ static, dynamic ]"
              exit 1
            end

            setup_type = _setup_type
          end
        end

        opts.on "update", "Update MobSF" do
          update = true
        end

        opts.missing_option do |option_flag|
          if option_flag == "-i" || option_flag == "--ip"
            @stderr.puts "ERROR: #{option_flag} is missing IP address."
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
          setup_mobsf(setup_type, dry_run)

          @stdout.puts "Done setting up MobSF! "
        end

        if update
          update_mobsf()
          @stdout.puts "Done updating MobSF!"
        end
      rescue ex
        puts "ERROR: #{ex.message}"
        puts opts
        exit(1)
      end
    end

    private def setup_mobsf(setup_type, dry_run)
      if setup_type == InstallType::STATIC || setup_type == ""
        @install_mob_dep_cmd.call(ARGV)

        @install_mob_framework_cmd.call(ARGV)

        update_mobsf()

        if setup_type == ""
          Dir.cd("../")
        end
      end
    end

    private def update_mobsf
      @update_mob_framework_cmd.call(ARGV)
    end
  end
end
