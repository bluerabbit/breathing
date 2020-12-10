require 'thor'
require 'breathing'

class Breathing
  class Cli < Thor
    default_command :version

    desc 'version', 'Show Version'
    def version
      say "Version: #{Breathing::VERSION}"
    end
  end
end
