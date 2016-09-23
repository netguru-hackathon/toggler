require "optparse"

module CommandLine
  Options = Struct.new(:description, :workspace, :billable)

  class Parser
    def self.parse(options)
      args = Options.new

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: toggler [options]"

        opts.on("-dDESCRIPTION", "--description=DESCRIPTION", "Add description to new entry") do |d|
          args.description = d
        end

        opts.on("-wWORKSPACE", "--workspace=WORKSPACE", "Add description to new entry") do |w|
          args.workspace = w
        end

        opts.on("-b", "--billable", "Set entry to billable (default non billable)") do
          args.billable = true
        end

        opts.on("-h", "--help", "Prints this help") do
          puts opts
          exit
        end
      end

      opt_parser.parse!(options)
      return args
    end
  end
end
