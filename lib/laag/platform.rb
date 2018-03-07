
# -*- ruby -*-

require 'rbconfig' # Ruby Standard Library

module LAAG
  module Platform
    HOST_OS = RbConfig::CONFIG['host_os'].downcase
    SOEXT   = RbConfig::CONFIG['SOEXT'] || RbConfig::CONFIG['DLEXT']
    SOGLOB  = (HOST_OS =~ /darwin/) ? "*.#{SOEXT}" : "#{SOEXT}.*"
  end
end
