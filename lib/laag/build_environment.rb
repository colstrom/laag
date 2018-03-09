
# -*- ruby -*-

require 'set' # Ruby Standard Library

module LAAG
  class BuildEnvironment
    DEFAULT_FEATURES = Set.new %w[autoconf autoreconf configure make]

    def initialize(library, **options)
      @library  = library
      @options  = options
      @enabled  = Set.new
      @disabled = Set.new
      %i[enable disable].each { |s| [*options[s]].each { |f| send s, f } }
      self
    end

    def script(&block)
      instance_eval(&block) if block_given?
    end

    def execute!(command, *arguments)
      STDOUT.puts ' -- ' + (commandline = [command, *arguments].flatten.map(&:to_s).join(' '))

      Dir.chdir(@library.source_path) do
        system(commandline).tap do |success|
          raise "Error: '#{commandline}' failed" unless success
        end
      end
    end

    def autoreconf!
      return unless enabled?(:autoreconf) and file?('configure.ac')
      execute! 'autoreconf', '--install'
    end

    def autogen!
      return unless enabled?(:autogen) and file?('autogen.sh')
      execute! './autogen.sh'
    end

    def configure!(*arguments)
      return unless enabled?(:configure)
      autogen!    unless file?('configure')
      autoreconf! unless file?('configure')
      return      unless file?('configure')
      execute! './configure', configure_options(arguments)
    end

    def make!(*arguments, make: ENV['MAKE'] || ENV['make'] || 'make')
      return     unless file?(makefile)
      execute! make, "-j#{make_jobs}", arguments
    end

    def configure_options(arguments)
      [
        ("--prefix=#{@library.install_path}" unless disabled?(:prefix)),
        ('--disable-dependency-tracking'     unless enabled?('dependency-tracking')),
        ('--enable-shared'                   unless disabled?(:shared)),
        ('--enable-static'                   unless disabled?(:static)),
        ('--with-pic'                        unless disabled?(:pic)),
        *arguments
      ].flatten.compact.uniq
    end

    def default!
      configure!
      make!
      make!(:clean)          unless disabled?('pre-clean')
      make! :install         unless disabled?(:install)
      make! :clean           unless disabled?('post-clean')
    end

    #############
    # Detection #
    #############

    def file?(filename)
      return unless filename
      File.exist? File.join(@library.source_path, filename.split('/'))
    end

    def makefile
      RbConfig::CONFIG['MAKEFILES'].split.find { |makefile| file? makefile } || 'Makefile'
    end

    def make_jobs
      @options.fetch(:make_jobs) do
        Etc.respond_to?(:nprocessors) ? Etc.nprocessors : ''
      end
    end

    #################
    # Feature Flags #
    #################

    def features
      DEFAULT_FEATURES
    end

    def disabled
      @disabled - @enabled
    end

    def enabled
      features - disabled
    end

    ######################
    # Flag State Queries #
    ######################

    def enabled?(feature)
      enabled.include? feature.to_s
    end

    def disabled?(feature)
      disabled.include? feature.to_s
    end

    ###########################
    # Flag State Manipulation #
    ###########################

    def enable(feature)
      feature.tap { @enabled << feature.to_s }
    end

    def unenable(feature)
      feature.tap { @enabled.delete feature.to_s }
    end

    def disable(feature)
      feature.tap { @disabled << feature.to_s }
    end

    def undisable(feature)
      feature.tap { @disabled.delete feature.to_s }
    end
  end
end
