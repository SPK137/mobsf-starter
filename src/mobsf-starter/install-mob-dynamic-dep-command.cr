require "./command-protocol"
require "option_parser"

module MobSFStarter
  class InstallMobDynamicDepCommand
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
      android_cl_win_url = "https://dl.google.com/android/repository/commandlinetools-win-9477386_latest.zip"
      android_cl_mac_url = "https://dl.google.com/android/repository/commandlinetools-mac-9477386_latest.zip"
      android_cl_linux_url = "https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip"

      android_cl_win_install_loc = "C:/Android/sdk"
      android_cl_mac_install_loc = "/Library/Android/sdk"
      android_cl_linux_install_loc = "/usr/local/android/sdk"

      STDOUT.puts "------------------------------------"
      STDOUT.puts "Fetching required packages..."
      STDOUT.puts "------------------------------------"

      fetchZipStatus = Process.run("sudo apt-get install zip unzip curl openjdk-11-jdk", shell: true, input: STDIN, output: STDOUT, error: STDERR)
      raise Exception.new("Error installing MobSF depedencies : zip") unless fetchZipStatus.success?

      STDOUT.puts "------------------------------------"
      STDOUT.puts "Setup Android Command Line Tool..."
      STDOUT.puts "------------------------------------"

      downloadAndroidCLStatus = Process.run("curl #{android_cl_linux_url} --output android_cl.zip", shell: true, input: STDIN, output: STDOUT, error: STDERR)
      raise Exception.new("Error installing MobSF depedencies : Download Android Command Line Tool") unless downloadAndroidCLStatus.success?

      unzipAndroidCLStatus = Process.run("unzip android_cl.zip && sudo rm -rf #{android_cl_linux_install_loc}/cmdline-tools/ && sudo mkdir --parents #{android_cl_linux_install_loc}/cmdline-tools/ && mv cmdline-tools tools && sudo mv tools #{android_cl_linux_install_loc}/cmdline-tools/", shell: true, input: STDIN, output: STDOUT, error: STDERR)
      raise Exception.new("Error installing MobSF depedencies : Unzipping Android Command Line Tool") unless unzipAndroidCLStatus.success?

      Process.run("rm android_cl.zip", shell: true, input: STDIN, output: STDOUT, error: STDERR)

      downloadSDKDepStatus = Process.run("sudo #{android_cl_linux_install_loc}/cmdline-tools/tools/bin/sdkmanager platform-tools emulator", shell: true, input: STDIN, output: STDOUT, error: STDERR)
      raise Exception.new("Error installing MobSF depedencies : Downloading platform-tools and emulator") unless downloadSDKDepStatus.success?

      STDOUT.puts "----------------------------------------"
      STDOUT.puts "Setting Environment Variables"
      STDOUT.puts "----------------------------------------"

      if File.exists?("~/.bashrc")
        Process.run("sed -i 's#export ANDROID_SDK_ROOT=#{android_cl_linux_install_loc}##' ~/.bashrc", shell: true, input: STDIN, output: STDOUT, error: STDERR)
        Process.run("sed -i 's#export ANDROID_HOME=#{android_cl_linux_install_loc}##' ~/.bashrc", shell: true, input: STDIN, output: STDOUT, error: STDERR)
        Process.run("sed -i 's#export MOBSF_ADB_BINARY=#{android_cl_linux_install_loc}/platform-tools/adb##' ~/.bashrc", shell: true, input: STDIN, output: STDOUT, error: STDERR)
        Process.run("sed -i 's#export PATH=$PATH:#{android_cl_linux_install_loc}/emulator:#{android_cl_linux_install_loc}/platform-tools:#{android_cl_linux_install_loc}/cmdline-tools/tools/bin##' ~/.bashrc", shell: true, input: STDIN, output: STDOUT, error: STDERR)
      end

      Process.run("echo 'export ANDROID_SDK_ROOT=#{android_cl_linux_install_loc}' >> ~/.bashrc", shell: true, input: STDIN, output: STDOUT, error: STDERR)
      Process.run("echo 'export ANDROID_HOME=#{android_cl_linux_install_loc}' >> ~/.bashrc", shell: true, input: STDIN, output: STDOUT, error: STDERR)
      Process.run("echo 'export MOBSF_ADB_BINARY=#{android_cl_linux_install_loc}/platform-tools/adb' >> ~/.bashrc", shell: true, input: STDIN, output: STDOUT, error: STDERR)

      Process.run("echo 'export PATH=$PATH:#{android_cl_linux_install_loc}/emulator:#{android_cl_linux_install_loc}/platform-tools:#{android_cl_linux_install_loc}/cmdline-tools/tools/bin' >> ~/.bashrc", shell: true, input: STDIN, output: STDOUT, error: STDERR)

      setEnvVarStatus = Process.run(%[. ~/.bashrc], shell: true, input: STDIN, output: STDOUT, error: STDERR)
      raise Exception.new("Error installing MobSF depedencies : Setting Environment Variables") unless setEnvVarStatus.success?

      STDOUT.puts "----------------------------------------"
      STDOUT.puts "Download Platform Specific Packages..."
      STDOUT.puts "----------------------------------------"

      downloadAndroidPkgStatus = Process.run(%[sudo #{android_cl_linux_install_loc}/cmdline-tools/tools/bin/sdkmanager "platforms;android-28" "system-images;android-28;default;x86" "build-tools;28.0.3" ], shell: true, input: STDIN, output: STDOUT, error: STDERR)
      raise Exception.new("Error installing MobSF depedencies : Download Platform Specific Packages") unless downloadAndroidPkgStatus.success?

      STDOUT.puts "----------------------------------------"
      STDOUT.puts "Create a AVD device..."
      STDOUT.puts "----------------------------------------"

      createAVDStatus = Process.run(%[sudo #{android_cl_linux_install_loc}/cmdline-tools/tools/bin/avdmanager create avd --force --name MobSF_Android --package "system-images;android-28;default;x86"], shell: true, input: STDIN, output: STDOUT, error: STDERR)
      raise Exception.new("Error installing MobSF depedencies : Download Platform Specific Packages") unless createAVDStatus.success?

      STDOUT.puts "Dependencies for MobSF's Dynamic Analysis installed!"
      STDOUT.puts "To start the emulator, run: emulator @MobSF_Android"
    end
  end
end
