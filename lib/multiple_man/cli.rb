require 'optparse'

module MultipleMan
  class Options < OptionParser
    def self.parse!(args)
      parser = new('Multiple Man')
      parser.set_opts.parse!(args)
      parser.options
    end

    attr_reader :options

    def initialize(*args)
      @options = { mode: :general, environment_path: 'config/environment' }
      super
    end

    def set_opts
      on('--seed', 'listen to the seeding queue') do
        options[:mode] = :seed
      end
      on('-e', '--environment-path PATH', 'Set the path to load the web framework (default: config/environment)') do |value|
        options[:environment_path] = value
      end
    end
  end

  module CLI
    module_function

    def run(args)
      options = Options.parse!(args)

      require options[:environment_path]

      Runner.new(mode: options[:mode]).run
    end
  end
end
