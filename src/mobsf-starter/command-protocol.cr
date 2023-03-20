require "option_parser"

module MobSFStarter::CommandProtocol
  abstract def call(args : Array(String))
end
