
# -*- ruby -*-

require 'rbconfig' # Ruby Standard Library

module LAAG
  class Library
    def initialize(gem_root:, origin:, version:, **options)
      @gem_root = gem_root
      @origin   = origin
      @version  = version
      @options  = options
      self
    end

    attr_reader :gem_root, :origin, :version

    def name
      @name ||= @options.fetch(:name) { origin.split('/').last.downcase }
    end

    def package_prefix
      @package_prefix ||= @options.fetch(:package_prefix) { 'package' }
    end

    def install_prefix
      @install_prefix ||= @options.fetch(:install_prefix) do
        File.join package_prefix, ".#{name}", version
      end
    end

    def vendor_prefix
      @vendor_prefix ||= @options.fetch(:vendor_prefix) { 'vendor' }
    end

    def install_path
      @install_path ||= File.join(gem_root, install_prefix)
    end

    def source_path
      @source_path ||= File.join(gem_root, vendor_prefix, @origin)
    end
  end
end
