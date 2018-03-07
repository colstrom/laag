
# -*- ruby -*-

module LAAG
  VERSION = $LOADED_FEATURES
              .map { |f| f.match %r{laag-(?<version>[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+(\.pre)?)} }
              .compact
              .map { |gem| gem['version'] }
              .uniq
              .first
end
