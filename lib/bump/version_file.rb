module Bump
  class VFile
    include Enumerable

    PRERELEASE    = ["alpha","beta","rc",nil]
    VERSION_REGEX = /(\d+\.\d+\.\d+(?:-(?:#{PRERELEASE.compact.join('|')}))?)/

    def self.version_from(file, regex=VERSION_REGEX)
      File.read(file.to_s)[regex, 1]
    rescue Errno::ENOENT
    end

    def path
      paths.tap do |files|
        raise TooManyVersionFilesError, files.join(", ") if files.size > 1
      end.first
    end

    def version
      self.class.version_from(path)
    end

    private

    def paths
      Dir.glob(self.class::GLOB)
    end

  end

  class VersionFile < VFile
    GLOB="VERSION"
  end

  class VersionRbFile < VFile
    GLOB="lib/**/version.rb"

    private

    def paths
      super.select do |file|
        self.class.version_from(file)
      end
    end
  end

  class GemspecFile < VFile
    GLOB="*.gemspec"

    def version
      self.class.version_from(path, /\.version\s*=\s*["']#{VERSION_REGEX}["']/) ||
        self.class.version_from(path, /Gem::Specification.new.+ ["']#{VERSION_REGEX}["']/)
    end
  end

  class LibRbFile < VFile
    GLOB="lib/**/*.rb"

    private

    def paths
      super.select do |file|
        self.class.version_from(file, /^\s+VERSION = ['"](#{VERSION_REGEX})['"]/i)
      end
    end
  end

  class ChefFile < VFile
    GLOB="metadata.rb"

    def version
      self.class.version_from(path, /^version\s+['"](#{VERSION_REGEX})['"]/)
    end
  end
end
